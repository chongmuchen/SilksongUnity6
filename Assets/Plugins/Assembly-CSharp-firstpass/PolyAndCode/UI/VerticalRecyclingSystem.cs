using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PolyAndCode.UI
{
	public class VerticalRecyclingSystem : RecyclingSystem
	{
		private readonly int _coloumns;

		private float _cellWidth;

		private float _cellHeight;

		private List<RectTransform> _cellPool;

		private List<ICell> _cachedCells;

		private Bounds _recyclableViewBounds;

		private readonly Vector3[] _corners = new Vector3[4];

		private bool _recycling;

		private int currentItemCount;

		private int topMostCellIndex;

		private int bottomMostCellIndex;

		private int _topMostCellColoumn;

		private int _bottomMostCellColoumn;

		private Vector2 zeroVector = Vector2.zero;

		public override int PoolCount => _cellPool.Count;

		public override int CurrentItemCount => currentItemCount;

		public override int CrossAxisCount => _coloumns;

		public override int CrossAxisOffset => _topMostCellColoumn;

		public override float CellSize => _cellHeight;

		public VerticalRecyclingSystem(RectTransform prototypeCell, RectTransform viewport, RectTransform content, IRecyclableScrollRectDataSource dataSource, bool isGrid, int coloumns)
		{
			PrototypeCell = prototypeCell;
			Viewport = viewport;
			Content = content;
			DataSource = dataSource;
			IsGrid = isGrid;
			_coloumns = ((!isGrid) ? 1 : coloumns);
			_recyclableViewBounds = default(Bounds);
		}

		public override IEnumerator InitCoroutine(Action onInitialized)
		{
			SetTopAnchor(Content);
			Content.anchoredPosition = Vector3.zero;
			yield return null;
			SetRecyclingBounds();
			CreateCellPool();
			currentItemCount = _cellPool.Count;
			topMostCellIndex = 0;
			bottomMostCellIndex = _cellPool.Count - 1;
			float y = (float)(int)Mathf.Ceil((float)_cellPool.Count / (float)_coloumns) * _cellHeight;
			Content.sizeDelta = new Vector2(Content.sizeDelta.x, y);
			SetTopAnchor(Content);
			onInitialized?.Invoke();
		}

		private void SetRecyclingBounds()
		{
			Viewport.GetWorldCorners(_corners);
			float num = RecyclingThreshold * (_corners[2].y - _corners[0].y);
			_recyclableViewBounds.min = new Vector3(_corners[0].x, _corners[0].y - num);
			_recyclableViewBounds.max = new Vector3(_corners[2].x, _corners[2].y + num);
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
			if (IsGrid)
			{
				SetTopLeftAnchor(PrototypeCell);
			}
			else
			{
				SetTopAnchor(PrototypeCell);
			}
			_topMostCellColoumn = (_bottomMostCellColoumn = 0);
			float num = 0f;
			int i = 0;
			float num2 = 0f;
			float num3 = 0f;
			_cellWidth = Content.rect.width / (float)_coloumns;
			_cellHeight = PrototypeCell.sizeDelta.y / PrototypeCell.sizeDelta.x * _cellWidth;
			float num4 = MinPoolCoverage * Viewport.rect.height;
			for (int num5 = Math.Min(MinPoolSize, DataSource.GetItemCount()); (i < num5 || num < num4) && i < DataSource.GetItemCount(); i++)
			{
				RectTransform component = UnityEngine.Object.Instantiate(PrototypeCell.gameObject).GetComponent<RectTransform>();
				component.name = "Cell";
				component.sizeDelta = new Vector2(_cellWidth, _cellHeight);
				_cellPool.Add(component);
				component.SetParent(Content, worldPositionStays: false);
				if (IsGrid)
				{
					num2 = (float)_bottomMostCellColoumn * _cellWidth;
					component.anchoredPosition = new Vector2(num2, num3);
					if (++_bottomMostCellColoumn >= _coloumns)
					{
						_bottomMostCellColoumn = 0;
						num3 -= _cellHeight;
						num += component.rect.height;
					}
				}
				else
				{
					component.anchoredPosition = new Vector2(0f, num3);
					num3 = component.anchoredPosition.y - component.rect.height;
					num += component.rect.height;
				}
				_cachedCells.Add(component.GetComponent<ICell>());
				DataSource.SetCell(_cachedCells[_cachedCells.Count - 1], i);
			}
			if (IsGrid)
			{
				_bottomMostCellColoumn = (_bottomMostCellColoumn - 1 + _coloumns) % _coloumns;
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
			if (direction.y > 0f && _cellPool[bottomMostCellIndex].MaxY() > _recyclableViewBounds.min.y)
			{
				return RecycleTopToBottom();
			}
			if (direction.y < 0f && _cellPool[topMostCellIndex].MinY() < _recyclableViewBounds.max.y)
			{
				return RecycleBottomToTop();
			}
			return zeroVector;
		}

		private Vector2 RecycleTopToBottom()
		{
			_recycling = true;
			int n = 0;
			float y = (IsGrid ? _cellPool[bottomMostCellIndex].anchoredPosition.y : 0f);
			float num = 0f;
			int num2 = 0;
			while (_cellPool[topMostCellIndex].MinY() > _recyclableViewBounds.max.y && currentItemCount < DataSource.GetItemCount())
			{
				if (IsGrid)
				{
					if (++_bottomMostCellColoumn >= _coloumns)
					{
						n++;
						_bottomMostCellColoumn = 0;
						y = _cellPool[bottomMostCellIndex].anchoredPosition.y - _cellHeight;
						num2++;
					}
					num = (float)_bottomMostCellColoumn * _cellWidth;
					_cellPool[topMostCellIndex].anchoredPosition = new Vector2(num, y);
					if (++_topMostCellColoumn >= _coloumns)
					{
						_topMostCellColoumn = 0;
						num2--;
					}
				}
				else
				{
					y = _cellPool[bottomMostCellIndex].anchoredPosition.y - _cellPool[bottomMostCellIndex].sizeDelta.y;
					_cellPool[topMostCellIndex].anchoredPosition = new Vector2(_cellPool[topMostCellIndex].anchoredPosition.x, y);
				}
				DataSource.SetCell(_cachedCells[topMostCellIndex], currentItemCount);
				bottomMostCellIndex = topMostCellIndex;
				topMostCellIndex = (topMostCellIndex + 1) % _cellPool.Count;
				currentItemCount++;
				if (!IsGrid)
				{
					n++;
				}
			}
			if (IsGrid)
			{
				Content.sizeDelta += num2 * Vector2.up * _cellHeight;
				if (num2 > 0)
				{
					n -= num2;
				}
			}
			_cellPool.ForEach(delegate(RectTransform cell)
			{
				cell.anchoredPosition += n * Vector2.up * _cellPool[topMostCellIndex].sizeDelta.y;
			});
			Content.anchoredPosition -= n * Vector2.up * _cellPool[topMostCellIndex].sizeDelta.y;
			_recycling = false;
			return -new Vector2(0f, (float)n * _cellPool[topMostCellIndex].sizeDelta.y);
		}

		private Vector2 RecycleBottomToTop()
		{
			_recycling = true;
			int n = 0;
			float y = (IsGrid ? _cellPool[topMostCellIndex].anchoredPosition.y : 0f);
			float num = 0f;
			int num2 = 0;
			while (_cellPool[bottomMostCellIndex].MaxY() < _recyclableViewBounds.min.y && currentItemCount > _cellPool.Count)
			{
				if (IsGrid)
				{
					if (--_topMostCellColoumn < 0)
					{
						n++;
						_topMostCellColoumn = _coloumns - 1;
						y = _cellPool[topMostCellIndex].anchoredPosition.y + _cellHeight;
						num2++;
					}
					num = (float)_topMostCellColoumn * _cellWidth;
					_cellPool[bottomMostCellIndex].anchoredPosition = new Vector2(num, y);
					if (--_bottomMostCellColoumn < 0)
					{
						_bottomMostCellColoumn = _coloumns - 1;
						num2--;
					}
				}
				else
				{
					y = _cellPool[topMostCellIndex].anchoredPosition.y + _cellPool[topMostCellIndex].sizeDelta.y;
					_cellPool[bottomMostCellIndex].anchoredPosition = new Vector2(_cellPool[bottomMostCellIndex].anchoredPosition.x, y);
					n++;
				}
				currentItemCount--;
				DataSource.SetCell(_cachedCells[bottomMostCellIndex], currentItemCount - _cellPool.Count);
				topMostCellIndex = bottomMostCellIndex;
				bottomMostCellIndex = (bottomMostCellIndex - 1 + _cellPool.Count) % _cellPool.Count;
			}
			if (IsGrid)
			{
				Content.sizeDelta += Vector2.up * ((float)num2 * _cellHeight);
				if (num2 > 0)
				{
					n -= num2;
				}
			}
			_cellPool.ForEach(delegate(RectTransform cell)
			{
				cell.anchoredPosition -= Vector2.up * ((float)n * _cellPool[topMostCellIndex].sizeDelta.y);
			});
			Content.anchoredPosition += Vector2.up * ((float)n * _cellPool[topMostCellIndex].sizeDelta.y);
			_recycling = false;
			return new Vector2(0f, (float)n * _cellPool[topMostCellIndex].sizeDelta.y);
		}

		private void SetTopAnchor(RectTransform rectTransform)
		{
			float width = rectTransform.rect.width;
			float height = rectTransform.rect.height;
			rectTransform.anchorMin = new Vector2(0.5f, 1f);
			rectTransform.anchorMax = new Vector2(0.5f, 1f);
			rectTransform.pivot = new Vector2(0.5f, 1f);
			rectTransform.sizeDelta = new Vector2(width, height);
		}

		private void SetTopLeftAnchor(RectTransform rectTransform)
		{
			float width = rectTransform.rect.width;
			float height = rectTransform.rect.height;
			rectTransform.anchorMin = new Vector2(0f, 1f);
			rectTransform.anchorMax = new Vector2(0f, 1f);
			rectTransform.pivot = new Vector2(0f, 1f);
			rectTransform.sizeDelta = new Vector2(width, height);
		}

		public void OnDrawGizmos()
		{
			Gizmos.color = Color.green;
			Gizmos.DrawLine(_recyclableViewBounds.min - new Vector3(2000f, 0f), _recyclableViewBounds.min + new Vector3(2000f, 0f));
			Gizmos.color = Color.red;
			Gizmos.DrawLine(_recyclableViewBounds.max - new Vector3(2000f, 0f), _recyclableViewBounds.max + new Vector3(2000f, 0f));
		}
	}
}
