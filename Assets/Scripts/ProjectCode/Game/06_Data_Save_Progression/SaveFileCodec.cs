using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using TeamCherry.SharedUtils;

/// <summary>
/// Encodes save JSON in a versioned container. The checksum detects accidental corruption; it is not an authenticity proof.
/// </summary>
public static class SaveFileCodec
{
	private const byte CurrentVersion = 1;

	private const byte EncryptedFlag = 1;

	private const int ChecksumLength = 32;

	private static readonly byte[] Magic = Encoding.ASCII.GetBytes("TCSAVE");

	private static readonly UTF8Encoding StrictUtf8 = new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true);

	private static int HeaderLength => Magic.Length + 1 + 1 + sizeof(int) + ChecksumLength;

	public static byte[] EncodeJson(string jsonData, bool useEncryption)
	{
		if (jsonData == null)
		{
			throw new ArgumentNullException(nameof(jsonData));
		}

		byte flags = useEncryption ? EncryptedFlag : (byte)0;
		string storedText = useEncryption ? Encryption.Encrypt(jsonData) : jsonData;
		byte[] payload = StrictUtf8.GetBytes(storedText);
		byte[] checksum = ComputeChecksum(CurrentVersion, flags, payload);

		using MemoryStream memoryStream = new MemoryStream(HeaderLength + payload.Length);
		using BinaryWriter writer = new BinaryWriter(memoryStream, StrictUtf8, leaveOpen: true);
		writer.Write(Magic);
		writer.Write(CurrentVersion);
		writer.Write(flags);
		writer.Write(payload.Length);
		writer.Write(checksum);
		writer.Write(payload);
		writer.Flush();
		return memoryStream.ToArray();
	}

	public static string DecodeJson(byte[] fileBytes, bool legacyUseEncryption)
	{
		if (fileBytes == null)
		{
			throw new ArgumentNullException(nameof(fileBytes));
		}

		if (HasEnvelopeHeader(fileBytes))
		{
			return DecodeEnvelope(fileBytes);
		}

		return DecodeLegacy(fileBytes, legacyUseEncryption);
	}

	private static bool HasEnvelopeHeader(byte[] fileBytes)
	{
		if (fileBytes.Length < Magic.Length)
		{
			return false;
		}

		for (int i = 0; i < Magic.Length; i++)
		{
			if (fileBytes[i] != Magic[i])
			{
				return false;
			}
		}

		return true;
	}

	private static string DecodeEnvelope(byte[] fileBytes)
	{
		if (fileBytes.Length < HeaderLength)
		{
			throw new InvalidDataException("Save data header is incomplete.");
		}

		using MemoryStream memoryStream = new MemoryStream(fileBytes, writable: false);
		using BinaryReader reader = new BinaryReader(memoryStream, StrictUtf8, leaveOpen: true);
		byte[] magic = reader.ReadBytes(Magic.Length);
		if (!BytesEqual(magic, Magic))
		{
			throw new InvalidDataException("Save data header is invalid.");
		}

		byte version = reader.ReadByte();
		if (version != CurrentVersion)
		{
			throw new InvalidDataException($"Unsupported save data format version: {version}.");
		}

		byte flags = reader.ReadByte();
		if ((flags & ~EncryptedFlag) != 0)
		{
			throw new InvalidDataException($"Save data contains unsupported flags: {flags}.");
		}

		int payloadLength = reader.ReadInt32();
		if (payloadLength < 0 || payloadLength != fileBytes.Length - HeaderLength)
		{
			throw new InvalidDataException("Save data payload length is invalid.");
		}

		byte[] storedChecksum = reader.ReadBytes(ChecksumLength);
		byte[] payload = reader.ReadBytes(payloadLength);
		if (storedChecksum.Length != ChecksumLength || payload.Length != payloadLength)
		{
			throw new InvalidDataException("Save data payload is incomplete.");
		}

		byte[] computedChecksum = ComputeChecksum(version, flags, payload);
		if (!BytesEqual(storedChecksum, computedChecksum))
		{
			throw new InvalidDataException("Save data checksum validation failed.");
		}

		string storedText = StrictUtf8.GetString(payload);
		return (flags & EncryptedFlag) != 0 ? Encryption.Decrypt(storedText) : storedText;
	}

	private static string DecodeLegacy(byte[] fileBytes, bool useEncryption)
	{
		if (!useEncryption)
		{
			return StrictUtf8.GetString(fileBytes);
		}

		string encryptedText = ReadLegacySerializedString(fileBytes);
		return Encryption.Decrypt(encryptedText);
	}

	private static string ReadLegacySerializedString(byte[] fileBytes)
	{
		// Old saves contain exactly one serialized string record. Parse only that record shape so arbitrary objects are never created.
		using MemoryStream memoryStream = new MemoryStream(fileBytes, writable: false);
		using BinaryReader reader = new BinaryReader(memoryStream, StrictUtf8, leaveOpen: true);

		if (reader.ReadByte() != 0)
		{
			throw new InvalidDataException("Legacy save data stream header is invalid.");
		}

		int rootId = reader.ReadInt32();
		int headerId = reader.ReadInt32();
		int majorVersion = reader.ReadInt32();
		int minorVersion = reader.ReadInt32();
		if (rootId <= 0 || headerId != -1 || majorVersion != 1 || minorVersion != 0)
		{
			throw new InvalidDataException("Legacy save data stream metadata is invalid.");
		}

		if (reader.ReadByte() != 6 || reader.ReadInt32() != rootId)
		{
			throw new InvalidDataException("Legacy save data does not contain the expected string payload.");
		}

		int byteLength = Read7BitEncodedInt(reader);
		long remainingLength = memoryStream.Length - memoryStream.Position;
		if (byteLength < 0 || byteLength > remainingLength - 1)
		{
			throw new InvalidDataException("Legacy save data string length is invalid.");
		}

		byte[] stringBytes = reader.ReadBytes(byteLength);
		if (stringBytes.Length != byteLength || reader.ReadByte() != 11 || memoryStream.Position != memoryStream.Length)
		{
			throw new InvalidDataException("Legacy save data stream is incomplete or contains unexpected records.");
		}

		return StrictUtf8.GetString(stringBytes);
	}

	private static int Read7BitEncodedInt(BinaryReader reader)
	{
		int value = 0;
		for (int shift = 0; shift < 35; shift += 7)
		{
			byte current = reader.ReadByte();
			if (shift == 28 && (current & 240) != 0)
			{
				throw new InvalidDataException("Legacy save data string length is too large.");
			}

			value |= (current & 127) << shift;
			if ((current & 128) == 0)
			{
				return value;
			}
		}

		throw new InvalidDataException("Legacy save data string length is invalid.");
	}

	private static byte[] ComputeChecksum(byte version, byte flags, byte[] payload)
	{
		byte[] data = new byte[payload.Length + 2];
		data[0] = version;
		data[1] = flags;
		Buffer.BlockCopy(payload, 0, data, 2, payload.Length);
		using SHA256 sha256 = SHA256.Create();
		return sha256.ComputeHash(data);
	}

	private static bool BytesEqual(byte[] left, byte[] right)
	{
		if (left == null || right == null || left.Length != right.Length)
		{
			return false;
		}

		int difference = 0;
		for (int i = 0; i < left.Length; i++)
		{
			difference |= left[i] ^ right[i];
		}
		return difference == 0;
	}
}
