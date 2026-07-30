using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PolyAndCode.UI
{
	public class HorizontalRecyclingSystem : RecyclingSystem
	{
		private readonly int _rows;

		private float _cellWidth;

		private float _cellHeight;

		private List<RectTransform> _cellPool;

		private List<ICell> _cachedCells;

		private Bounds _recyclableViewBounds;

		private readonly Vector3[] _corners = new Vector3[4];

		private bool _recycling;

		private int currentItemCount;

		private int leftMostCellIndex;

		private int rightMostCellIndex;

		private int _leftMostCellRow;

		private int _RightMostCellRow;

		private Vector2 zeroVector = Vector2.zero;

		public override int PoolCount => _cellPool.Count;

		public override int CurrentItemCount => currentItemCount;

		public override int CrossAxisCount => _rows;

		public override int CrossAxisOffset => _leftMostCellRow;

		public override float CellSize => _cellWidth;

		public HorizontalRecyclingSystem(RectTransform prototypeCell, RectTransform viewport, RectTransform content, IRecyclableScrollRectDataSource dataSource, bool isGrid, int rows)
		{
			PrototypeCell = prototypeCell;
			Viewport = viewport;
			Content = content;
			DataSource = dataSource;
			IsGrid = isGrid;
			_rows = ((!isGrid) ? 1 : rows);
			_recyclableViewBounds = default(Bounds);
		}

		public override IEnumerator InitCoroutine(Action onInitialized)
		{
			SetLeftAnchor(Content);
			Content.anchoredPosition = Vector3.zero;
			yield return null;
			SetRecyclingBounds();
			CreateCellPool();
			currentItemCount = _cellPool.Count;
			leftMostCellIndex = 0;
			rightMostCellIndex = _cellPool.Count - 1;
			float x = (float)Mathf.CeilToInt((float)_cellPool.Count / (float)_rows) * _cellWidth;
			Content.sizeDelta = new Vector2(x, Content.sizeDelta.y);
			SetLeftAnchor(Content);
			onInitialized?.Invoke();
		}

		private void SetRecyclingBounds()
		{
			Viewport.GetWorldCorners(_corners);
			float num = RecyclingThreshold * (_corners[2].x - _corners[0].x);
			_recyclableViewBounds.min = new Vector3(_corners[0].x - num, _corners[0].y);
			_recyclableViewBounds.max = new Vector3(_corners[2].x + num, _corners[2].y);
		}

		public override void CreateCellPool()
		{
			if (_cellPool != null)
			{
				return;
			}
			_cachedCells = new List<ICell>();
			_cellPool = new List<RectTransform>();
			PrototypeCell.gameObject.SetActive(value: true);
			SetLeftAnchor(PrototypeCell);
			_cellHeight = Content.rect.height / (float)_rows;
			_cellWidth = PrototypeCell.sizeDelta.x / PrototypeCell.sizeDelta.y * _cellHeight;
			_leftMostCellRow = (_RightMostCellRow = 0);
			float num = 0f;
			int i = 0;
			float num2 = 0f;
			float num3 = 0f;
			float num4 = MinPoolCoverage * Viewport.rect.width;
			for (int num5 = Math.Min(MinPoolSize, DataSource.GetItemCount()); (i < num5 || num < num4) && i < DataSource.GetItemCount(); i++)
			{
				RectTransform component = UnityEngine.Object.Instantiate(PrototypeCell.gameObject).GetComponent<RectTransform>();
				component.name = "Cell";
				component.sizeDelta = new Vector2(_cellWidth, _cellHeight);
				_cellPool.Add(component);
				component.SetParent(Content, worldPositionStays: false);
				if (IsGrid)
				{
					num3 = (float)(-_RightMostCellRow) * _cellHeight;
					component.anchoredPosition = new Vector2(num2, num3);
					if (++_RightMostCellRow >= _rows)
					{
						_RightMostCellRow = 0;
						num2 += _cellWidth;
						num += component.rect.width;
					}
				}
				else
				{
					component.anchoredPosition = new Vector2(num2, 0f);
					num2 = component.anchoredPosition.x + component.rect.width;
					num += component.rect.width;
				}
				_cachedCells.Add(component.GetComponent<ICell>());
				DataSource.SetCell(_cachedCells[_cachedCells.Count - 1], i);
			}
			if (IsGrid)
			{
				_RightMostCellRow = (_RightMostCellRow - 1 + _rows) % _rows;
			}
			if (PrototypeCell.gameObject.scene.IsValid())
			{
				PrototypeCell.gameObject.SetActive(value: false);
			}
		}

		public override Vector2 OnValueChangedListener(Vector2 direction)
		{
			if (_recycling || _cellPool == null || _cellPool.Count == 0)
			{
				return zeroVector;
			}
			SetRecyclingBounds();
			if (direction.x < 0f && _cellPool[rightMostCellIndex].MinX() < _recyclableViewBounds.max.x)
			{
				return RecycleLeftToRight();
			}
			if (direction.x > 0f && _cellPool[leftMostCellIndex].MaxX() > _recyclableViewBounds.min.x)
			{
				return RecycleRightToleft();
			}
			return zeroVector;
		}

		private Vector2 RecycleLeftToRight()
		{
			_recycling = true;
			int n = 0;
			float x = (IsGrid ? _cellPool[rightMostCellIndex].anchoredPosition.x : 0f);
			float num = 0f;
			int num2 = 0;
			while (_cellPool[leftMostCellIndex].MaxX() < _recyclableViewBounds.min.x && currentItemCount < DataSource.GetItemCount())
			{
				if (IsGrid)
				{
					if (++_RightMostCellRow >= _rows)
					{
						n++;
						_RightMostCellRow = 0;
						x = _cellPool[rightMostCellIndex].anchoredPosition.x + _cellWidth;
						num2++;
					}
					num = (float)(-_RightMostCellRow) * _cellHeight;
					_cellPool[leftMostCellIndex].anchoredPosition = new Vector2(x, num);
					if (++_leftMostCellRow >= _rows)
					{
						_leftMostCellRow = 0;
						num2--;
					}
				}
				else
				{
					x = _cellPool[rightMostCellIndex].anchoredPosition.x + _cellPool[rightMostCellIndex].sizeDelta.x;
					_cellPool[leftMostCellIndex].anchoredPosition = new Vector2(x, _cellPool[leftMostCellIndex].anchoredPosition.y);
				}
				DataSource.SetCell(_cachedCells[leftMostCellIndex], currentItemCount);
				rightMostCellIndex = leftMostCellIndex;
				leftMostCellIndex = (leftMostCellIndex + 1) % _cellPool.Count;
				currentItemCount++;
				if (!IsGrid)
				{
					n++;
				}
			}
			if (IsGrid)
			{
				Content.sizeDelta += num2 * Vector2.right * _cellWidth;
				if (num2 > 0)
				{
					n -= num2;
				}
			}
			_cellPool.ForEach(delegate(RectTransform cell)
			{
				cell.anchoredPosition -= n * Vector2.right * _cellPool[leftMostCellIndex].sizeDelta.x;
			});
			Content.anchoredPosition += n * Vector2.right * _cellPool[leftMostCellIndex].sizeDelta.x;
			_recycling = false;
			return n * Vector2.right * _cellPool[leftMostCellIndex].sizeDelta.x;
		}

		private Vector2 RecycleRightToleft()
		{
			_recycling = true;
			int n = 0;
			float x = (IsGrid ? _cellPool[leftMostCellIndex].anchoredPosition.x : 0f);
			float num = 0f;
			int num2 = 0;
			while (_cellPool[rightMostCellIndex].MinX() > _recyclableViewBounds.max.x && currentItemCount > _cellPool.Count)
			{
				if (IsGrid)
				{
					if (--_leftMostCellRow < 0)
					{
						n++;
						_leftMostCellRow = _rows - 1;
						x = _cellPool[leftMostCellIndex].anchoredPosition.x - _cellWidth;
						num2++;
					}
					num = (float)(-_leftMostCellRow) * _cellHeight;
					_cellPool[rightMostCellIndex].anchoredPosition = new Vector2(x, num);
					if (--_RightMostCellRow < 0)
					{
						_RightMostCellRow = _rows - 1;
						num2--;
					}
				}
				else
				{
					x = _cellPool[leftMostCellIndex].anchoredPosition.x - _cellPool[leftMostCellIndex].sizeDelta.x;
					_cellPool[rightMostCellIndex].anchoredPosition = new Vector2(x, _cellPool[rightMostCellIndex].anchoredPosition.y);
					n++;
				}
				currentItemCount--;
				DataSource.SetCell(_cachedCells[rightMostCellIndex], currentItemCount - _cellPool.Count);
				leftMostCellIndex = rightMostCellIndex;
				rightMostCellIndex = (rightMostCellIndex - 1 + _cellPool.Count) % _cellPool.Count;
			}
			if (IsGrid)
			{
				Content.sizeDelta += num2 * Vector2.right * _cellWidth;
				if (num2 > 0)
				{
					n -= num2;
				}
			}
			_cellPool.ForEach(delegate(RectTransform cell)
			{
				cell.anchoredPosition += n * Vector2.right * _cellPool[leftMostCellIndex].sizeDelta.x;
			});
			Content.anchoredPosition -= n * Vector2.right * _cellPool[leftMostCellIndex].sizeDelta.x;
			_recycling = false;
			return -n * Vector2.right * _cellPool[leftMostCellIndex].sizeDelta.x;
		}

		private void SetLeftAnchor(RectTransform rectTransform)
		{
			float width = rectTransform.rect.width;
			float height = rectTransform.rect.height;
			Vector2 pivot = (rectTransform.anchorMax = (rectTransform.anchorMin = (IsGrid ? new Vector2(0f, 1f) : new Vector2(0f, 0.5f))));
			rectTransform.pivot = pivot;
			rectTransform.sizeDelta = new Vector2(width, height);
		}

		public void OnDrawGizmos()
		{
			Gizmos.color = Color.green;
			Gizmos.DrawLine(_recyclableViewBounds.min - new Vector3(0f, 2000f), _recyclableViewBounds.min + new Vector3(0f, 2000f));
			Gizmos.color = Color.red;
			Gizmos.DrawLine(_recyclableViewBounds.max - new Vector3(0f, 2000f), _recyclableViewBounds.max + new Vector3(0f, 2000f));
		}
	}
}
