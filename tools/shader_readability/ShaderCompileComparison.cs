using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

// Copy into the validation project's Assets/Editor and run with
// -executeMethod ShaderCompileComparison.Run. The project root supplies input.json.
// Public API verified against UnityCsReference's 6000.5 branch:
// https://github.com/Unity-Technologies/UnityCsReference/blob/6000.5/Editor/Mono/ShaderUtil.cs
public static class ShaderCompileComparison
{
    [Serializable] public class Input { public ShaderInput[] shaders; }
    [Serializable] public class CandidateManifest { public string baseline; }
    [Serializable] public class ShaderInput
    {
        public string path;
        public int renderPassCount, serializedPassCount;
        public PassInput[] passes;
    }
    [Serializable] public class PassInput
    {
        public int subshader, index, ordinal;
        public VariantInput[] variants;
    }
    [Serializable] public class VariantInput { public string[] keywords; }

    [Serializable] public class NamedCount { public string name; public int count; }
    [Serializable] public class SourceMetrics
    {
        public int sampleCalls, sampleCompareCalls, gatherCalls, readCalls;
        public int arithmeticOperatorTokens, branchTokens, loopTokens;
        public List<NamedCount> intrinsicCalls = new List<NamedCount>();
    }
    [Serializable] public class TextureBinding
    {
        public string name, dimension;
        public int index, samplerIndex, arraySize;
        public bool multisampled;
    }
    [Serializable] public class ConstantField
    {
        public string name, constantType, dataType;
        public int offset, rows, columns, arraySize, structSize;
        public List<ConstantField> structFields;
    }
    [Serializable] public class ConstantBuffer
    {
        public string name;
        public int size;
        public List<ConstantField> fields;
    }
    [Serializable] public class CompiledStage
    {
        public bool success, metalSourceAvailable;
        public int byteCount;
        public string error, rawSha256, normalizedMetalSha256;
        public string binaryPath, textPath, normalizedMetalPath;
        public List<string> messages = new List<string>();
        public List<TextureBinding> textures = new List<TextureBinding>();
        public List<ConstantBuffer> constantBuffers = new List<ConstantBuffer>();
        public SourceMetrics sourceMetrics;
    }
    [Serializable] public class Comparison
    {
        public string path, stage;
        public int subshader, passOrdinal, baselinePassIndex, currentPassIndex;
        public string[] keywords;
        public CompiledStage baseline, current;
        public bool rawBytesIdentical, normalizedMetalComparable, normalizedMetalIdentical;
        public bool textureBindingsIdentical, constantBuffersIdentical, sourceMetricsIdentical;
        public int sampleCallDelta, arithmeticOperatorTokenDelta;
    }
    [Serializable] public class Report
    {
        public string baselineRevision, candidateManifestSha256;
        public string unity, compilerPlatform = "Metal", buildTarget = "StandaloneOSX";
        public string colorSpace, error;
        public string scope = "Subshader 0; vertex and fragment stages for every input keyword combination. " +
            "Each side uses ShaderData.Pass.CompileVariant with the same target settings.";
        public string metricsMeaning = "Counts are static syntax in the returned Metal source: texture method calls, " +
            "arithmetic operator tokens and named intrinsic calls. They are not hardware instructions, cycles, " +
            "register pressure or a GPU timing measurement. Loops and vector widths are not weighted.";
        public string normalization = "Comments, whitespace, line directives and the explicit Lit struct/interface renames only.";
        public int shaderCount, stageComparisons, compileFailures, rawIdenticalCount;
        public int metalComparableCount, normalizedMetalIdenticalCount, sourceMetricsIdenticalCount;
        public bool allCompilesSucceeded, allRawIdentical, allNormalizedMetalIdentical;
        public List<Comparison> comparisons = new List<Comparison>();
    }

    public static void Run()
    {
        var root = Directory.GetParent(Application.dataPath).FullName;
        var output = Path.Combine(root, "results");
        var compiled = Path.Combine(root, "compiled");
        Directory.CreateDirectory(output);
        Directory.CreateDirectory(compiled);
        var report = new Report { unity = Application.unityVersion,
            colorSpace = QualitySettings.activeColorSpace.ToString() };
        bool previousAsync = ShaderUtil.allowAsyncCompilation;
        try
        {
            ShaderUtil.allowAsyncCompilation = false;
            string manifestPath = Path.Combine(root, "candidate-manifest.json");
            report.candidateManifestSha256 = Hash(File.ReadAllBytes(manifestPath));
            report.baselineRevision = JsonUtility.FromJson<CandidateManifest>(File.ReadAllText(manifestPath)).baseline;
            var input = JsonUtility.FromJson<Input>(File.ReadAllText(Path.Combine(root, "input.json")));
            if (input == null || input.shaders == null || input.shaders.Length == 0)
                throw new InvalidOperationException("input.json contains no shaders");
            foreach (var info in input.shaders)
            {
                if (String.IsNullOrEmpty(info.path) || !info.path.StartsWith("Assets/", StringComparison.Ordinal))
                    throw new InvalidOperationException("Expected an Assets/ shader path");
                string baselinePath = "Assets/ReadabilityBaseline/" + info.path.Substring(7);
                var current = AssetDatabase.LoadAssetAtPath<Shader>(info.path);
                var baseline = AssetDatabase.LoadAssetAtPath<Shader>(baselinePath);
                if (!current || !baseline || current == baseline)
                    throw new InvalidOperationException("Missing or aliased shader pair: " + info.path);
                var currentSubshader = ShaderUtil.GetShaderData(current).GetSubshader(0);
                var baselineSubshader = ShaderUtil.GetShaderData(baseline).GetSubshader(0);
                if (currentSubshader == null || baselineSubshader == null)
                    throw new InvalidOperationException("Missing subshader 0: " + info.path);
                foreach (var pass in info.passes ?? new PassInput[0])
                {
                    if (pass.subshader != 0) continue;
                    // Unity can expose either render-only or serialized pass indices.
                    // GrabPass is present in the latter; use the input's matching index.
                    int currentIndex = currentSubshader.PassCount == info.renderPassCount ? pass.ordinal : pass.index;
                    int baselineIndex = baselineSubshader.PassCount == info.renderPassCount ? pass.ordinal : pass.index;
                    var currentPass = currentSubshader.GetPass(currentIndex);
                    var baselinePass = baselineSubshader.GetPass(baselineIndex);
                    if (currentPass == null || baselinePass == null || currentPass.IsGrabPass || baselinePass.IsGrabPass)
                        throw new InvalidOperationException("Invalid render pass ordinal " + pass.ordinal + ": " + info.path);
                    foreach (var variant in pass.variants ?? new VariantInput[0])
                    {
                        var keywords = variant.keywords ?? new string[0];
                        foreach (ShaderType stage in new[] { ShaderType.Vertex, ShaderType.Fragment })
                        {
                            int index = report.comparisons.Count;
                            string prefix = index.ToString("D5") + "-" + Path.GetFileNameWithoutExtension(info.path) + "-" + stage;
                            var row = new Comparison { path = info.path, subshader = 0, passOrdinal = pass.ordinal,
                                baselinePassIndex = baselineIndex, currentPassIndex = currentIndex,
                                keywords = keywords, stage = stage.ToString() };
                            row.baseline = Compile(baselinePass, stage, keywords, compiled, prefix + "-baseline");
                            row.current = Compile(currentPass, stage, keywords, compiled, prefix + "-current");
                            row.rawBytesIdentical = row.baseline.success && row.current.success &&
                                row.baseline.byteCount > 0 && row.baseline.rawSha256 == row.current.rawSha256;
                            row.normalizedMetalComparable = row.baseline.metalSourceAvailable && row.current.metalSourceAvailable;
                            row.normalizedMetalIdentical = row.normalizedMetalComparable &&
                                row.baseline.normalizedMetalSha256 == row.current.normalizedMetalSha256;
                            row.textureBindingsIdentical = JsonUtility.ToJson(new TextureList { values = row.baseline.textures }) ==
                                JsonUtility.ToJson(new TextureList { values = row.current.textures });
                            row.constantBuffersIdentical = JsonUtility.ToJson(new BufferList { values = row.baseline.constantBuffers }) ==
                                JsonUtility.ToJson(new BufferList { values = row.current.constantBuffers });
                            if (row.normalizedMetalComparable)
                            {
                                row.sourceMetricsIdentical = JsonUtility.ToJson(row.baseline.sourceMetrics) == JsonUtility.ToJson(row.current.sourceMetrics);
                                row.sampleCallDelta = row.current.sourceMetrics.sampleCalls - row.baseline.sourceMetrics.sampleCalls;
                                row.arithmeticOperatorTokenDelta = row.current.sourceMetrics.arithmeticOperatorTokens - row.baseline.sourceMetrics.arithmeticOperatorTokens;
                            }
                            report.comparisons.Add(row);
                        }
                    }
                }
                report.shaderCount++;
                Summarize(report);
                File.WriteAllText(Path.Combine(output, "compiled-progress.json"), JsonUtility.ToJson(report, true));
                Debug.Log("SHADER_COMPILE_COMPARISON shader=" + report.shaderCount + " stages=" + report.stageComparisons + " path=" + info.path);
            }
        }
        catch (Exception error)
        {
            report.error = error.ToString();
            Debug.LogException(error);
        }
        finally { ShaderUtil.allowAsyncCompilation = previousAsync; }
        Summarize(report);
        File.WriteAllText(Path.Combine(output, "compiled.json"), JsonUtility.ToJson(report, true));
        Debug.Log("SHADER_COMPILE_COMPARISON_FINISHED success=" + report.allCompilesSucceeded +
            " comparisons=" + report.stageComparisons + " rawIdentical=" + report.rawIdenticalCount +
            " normalizedMetalIdentical=" + report.normalizedMetalIdenticalCount);
        EditorApplication.Exit(report.allCompilesSucceeded ? 0 : 1);
    }

    [Serializable] class TextureList { public List<TextureBinding> values; }
    [Serializable] class BufferList { public List<ConstantBuffer> values; }

    static void Summarize(Report report)
    {
        report.stageComparisons = report.comparisons.Count;
        report.compileFailures = report.comparisons.Sum(c => (c.baseline.success ? 0 : 1) + (c.current.success ? 0 : 1));
        report.rawIdenticalCount = report.comparisons.Count(c => c.rawBytesIdentical);
        report.metalComparableCount = report.comparisons.Count(c => c.normalizedMetalComparable);
        report.normalizedMetalIdenticalCount = report.comparisons.Count(c => c.normalizedMetalIdentical);
        report.sourceMetricsIdenticalCount = report.comparisons.Count(c => c.sourceMetricsIdentical);
        report.allCompilesSucceeded = report.stageComparisons > 0 && report.compileFailures == 0 && String.IsNullOrEmpty(report.error);
        report.allRawIdentical = report.allCompilesSucceeded && report.rawIdenticalCount == report.stageComparisons;
        report.allNormalizedMetalIdentical = report.allCompilesSucceeded && report.normalizedMetalIdenticalCount == report.stageComparisons;
    }

    static CompiledStage Compile(ShaderData.Pass pass, ShaderType stage, string[] keywords, string directory, string prefix)
    {
        var result = new CompiledStage();
        try
        {
            if (!pass.HasShaderStage(stage)) throw new InvalidOperationException("Shader pass has no " + stage + " stage");
            var variant = pass.CompileVariant(stage, keywords, ShaderCompilerPlatform.Metal, BuildTarget.StandaloneOSX);
            result.success = variant.Success;
            foreach (var message in variant.Messages ?? new ShaderMessage[0])
                result.messages.Add(message.severity + " " + message.file + ":" + message.line + " " + message.message);
            foreach (var texture in variant.TextureBindings ?? new ShaderData.TextureBindingInfo[0])
                result.textures.Add(new TextureBinding { name = texture.Name, index = texture.Index,
                    samplerIndex = texture.SamplerIndex, dimension = texture.Dim.ToString(),
                    arraySize = texture.ArraySize, multisampled = texture.Multisampled });
            foreach (var buffer in variant.ConstantBuffers ?? new ShaderData.ConstantBufferInfo[0])
                result.constantBuffers.Add(new ConstantBuffer { name = buffer.Name, size = buffer.Size, fields = Fields(buffer.Fields) });
            byte[] bytes = variant.ShaderData ?? new byte[0];
            result.byteCount = bytes.Length;
            result.rawSha256 = Hash(bytes);
            result.binaryPath = "compiled/" + prefix + ".bin";
            File.WriteAllBytes(Path.Combine(directory, prefix + ".bin"), bytes);
            string decoded = Encoding.UTF8.GetString(bytes);
            string metal = ExtractMetal(decoded);
            result.metalSourceAvailable = metal != null;
            result.textPath = "compiled/" + prefix + (metal == null ? ".txt" : ".metal");
            File.WriteAllText(Path.Combine(directory, prefix + (metal == null ? ".txt" : ".metal")), metal ?? decoded);
            if (metal != null)
            {
                string normalized = NormalizeMetal(metal);
                result.normalizedMetalSha256 = Hash(Encoding.UTF8.GetBytes(normalized));
                result.normalizedMetalPath = "compiled/" + prefix + ".normalized.metal";
                File.WriteAllText(Path.Combine(directory, prefix + ".normalized.metal"), normalized);
                result.sourceMetrics = Metrics(metal);
            }
            if (result.success && bytes.Length == 0)
            {
                result.success = false;
                result.error = "CompileVariant reported success but returned no ShaderData";
            }
        }
        catch (Exception error) { result.success = false; result.error = error.ToString(); }
        File.WriteAllText(Path.Combine(directory, prefix + ".json"), JsonUtility.ToJson(result, true));
        return result;
    }

    static List<ConstantField> Fields(ShaderData.ConstantInfo[] fields)
    {
        return (fields ?? new ShaderData.ConstantInfo[0]).Select(field => new ConstantField {
            name = field.Name, offset = field.Index, constantType = field.ConstantType.ToString(),
            // DataType is meaningful for leaf constants only; Unity may return an
            // unspecified native value for a struct container. Its fields carry the types.
            dataType = field.ConstantType.ToString() == "Struct" ? "NotApplicable" : field.DataType.ToString(),
            rows = field.Rows, columns = field.Columns,
            arraySize = field.ArraySize, structSize = field.StructSize,
            structFields = Fields(field.StructFields) }).ToList();
    }

    static string Hash(byte[] bytes)
    {
        using (var sha = SHA256.Create())
            return BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
    }

    static string ExtractMetal(string decoded)
    {
        // ShaderData may contain a platform header and a null-terminated MSL payload.
        // Never count UTF-8 decoded binary bytes as shader instructions or source.
        var marker = Regex.Match(decoded, @"#include\s*[<" + "\"" + @"]metal_stdlib[>" + "\"" + @"]");
        if (!marker.Success) return null;
        int end = decoded.IndexOf('\0', marker.Index);
        string source = end < 0 ? decoded.Substring(marker.Index) : decoded.Substring(marker.Index, end - marker.Index);
        if (source.IndexOf('\uFFFD') >= 0 || !Regex.IsMatch(source, @"\b(vertex|fragment)\b")) return null;
        return source;
    }

    static string StripSourceMetadata(string source)
    {
        source = Regex.Replace(source, @"//[^\n]*|/\*[\s\S]*?\*/", "");
        return Regex.Replace(source, @"^\s*#(?:line\s+.*|\s*\d+\s+.*)$", "", RegexOptions.Multiline);
    }

    static string NormalizeMetal(string source)
    {
        source = StripSourceMetadata(source);
        source = Regex.Replace(source, @"RV_[a-f0-9]+_Input\b", "SpriteVertexInput");
        source = Regex.Replace(source, @"RV_[a-f0-9]+_Output\b", "SpriteVertexOutput");
        source = Regex.Replace(source, @"RF_[a-f0-9]+_Input\b", "SpriteFragmentInput");
        source = Regex.Replace(source, @"RF_[a-f0-9]+_Output\b", "SpriteFragmentOutput");
        string[,] names = { { "POSITION0", "positionOS" }, { "COLOR0", "color" }, { "TEXCOORD0", "uv" },
            { "SV_Target0", "color" }, { "mtl_Position", "positionCS" }, { "recovered_InstanceID", "instanceID" },
            { "mtl_FragCoord", "positionSS" }, { "hlslcc_FragCoord", "fragmentCoord" } };
        for (int i = 0; i < names.GetLength(0); ++i)
            source = Regex.Replace(source, @"\b" + names[i, 0] + @"\b", names[i, 1]);
        return String.Join(" ", Regex.Matches(source, @"\w+|[^\s\w]").Cast<Match>().Select(match => match.Value));
    }

    static SourceMetrics Metrics(string source)
    {
        source = StripSourceMetadata(source);
        source = Regex.Replace(source, @"^\s*#.*$", "", RegexOptions.Multiline);
        var metrics = new SourceMetrics {
            sampleCalls = Regex.Matches(source, @"\.\s*sample\s*\(").Count,
            sampleCompareCalls = Regex.Matches(source, @"\.\s*sample_compare\s*\(").Count,
            gatherCalls = Regex.Matches(source, @"\.\s*gather(?:_compare)?\s*\(").Count,
            readCalls = Regex.Matches(source, @"\.\s*read\s*\(").Count,
            arithmeticOperatorTokens = Regex.Matches(source, @"\+\+|--|\+=|-=|\*=|/=|[+*/%\-]").Count,
            branchTokens = Regex.Matches(source, @"\b(if|switch)\b|\?").Count,
            loopTokens = Regex.Matches(source, @"\b(for|while|do)\b").Count,
        };
        foreach (string name in new[] { "abs", "ceil", "clamp", "cos", "cross", "dot", "exp", "exp2", "floor", "fma", "fract",
            "length", "log", "log2", "mad", "max", "min", "mix", "normalize", "pow", "rint", "round", "rsqrt", "saturate", "sin", "sqrt", "step" })
        {
            int count = Regex.Matches(source, @"\b" + name + @"\s*\(").Count;
            if (count > 0) metrics.intrinsicCalls.Add(new NamedCount { name = name, count = count });
        }
        return metrics;
    }
}
