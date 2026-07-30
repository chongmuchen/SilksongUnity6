using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;

namespace TeamCherry.GameCore
{
	public sealed class GameCoreSaveHandler : IDisposable
	{
		[StructLayout(LayoutKind.Sequential, Size = 1)]
		public struct XUserHandle
		{
		}

		public delegate void InitializeCallback(int hresult);

		public delegate void GetQuotaCallback(int hresult, long remainingQuota);

		public delegate void QueryContainersCallback(int hresult, string[] containerNames);

		public delegate void QueryBlobsCallback(int hresult, Dictionary<string, uint> blobInfos);

		public delegate void LoadCallback(int hresult, byte[] blobData);

		public delegate void SaveCallback(int hresult);

		public delegate void DeleteCallback(int hresult);

		private delegate void UpdateCallback(int hresult);

		private int activeOperations;

		private bool isInitialising;

		private bool isDisposed;

		public bool IsInitialised { get; private set; }

		public int ActiveOperations => activeOperations;

		~GameCoreSaveHandler()
		{
			ReleaseUnmanagedResources();
		}

		private void ReleaseUnmanagedResources()
		{
			if (!isDisposed)
			{
				isDisposed = true;
			}
		}

		public void Dispose()
		{
			ReleaseUnmanagedResources();
			GC.SuppressFinalize(this);
		}

		public void InitializeAsync(XUserHandle userHandle, string scid, InitializeCallback callback)
		{
			if (!isInitialising && !IsInitialised && !isDisposed)
			{
				isInitialising = true;
				callback(0);
			}
		}

		private void StartOperation()
		{
			Interlocked.Increment(ref activeOperations);
		}

		private void FinishOperation()
		{
			Interlocked.Decrement(ref activeOperations);
		}

		public void GetQuotaAsync(GetQuotaCallback callback)
		{
			callback(0, 0L);
		}

		public void QueryContainers(string containerNamePrefix, QueryContainersCallback callback)
		{
			callback(0, new string[0]);
		}

		public void QueryContainerBlobs(string containerName, QueryBlobsCallback callback)
		{
			callback(0, new Dictionary<string, uint>());
		}

		public void Load(string containerName, string blobName, LoadCallback callback)
		{
			callback(0, new byte[0]);
		}

		public void Save(string containerName, string blobName, byte[] blobData, SaveCallback callback)
		{
			callback(0);
		}

		public void Delete(string containerName, DeleteCallback callback)
		{
			callback(0);
		}

		public void Delete(string containerName, string blobName, DeleteCallback callback)
		{
			callback(0);
		}

		public void Delete(string containerName, string[] blobNames, DeleteCallback callback)
		{
			callback(0);
		}

		private void Update(string containerName, IDictionary<string, byte[]> blobsToSave, IList<string> blobsToDelete, UpdateCallback callback)
		{
			callback(0);
		}
	}
}
