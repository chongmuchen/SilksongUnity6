using System;
using UnityEngine;
using UnityEngine.UI;

namespace PolyAndCode.UI
{
	public class RecyclableScrollRect : ScrollRect
	{
		public enum DirectionType
		{
			Vertical = 0,
			Horizontal = 1
		}

		[HideInInspector]
		public IRecyclableScrollRectDataSource DataSource;

		[SerializeField]
		private Scrollbar scrollbar;

		private float previousScrollAmount;

		public bool IsGrid;

		public RectTransform PrototypeCell;

		public bool SelfInitialize = true;

		public DirectionType Direction;

		[SerializeField]
		private int _segments;

		private RecyclingSystem _recyclingSystem;

		private Vector2 _prevAnchoredPos;

		private bool hasGridLayoutGroup;

		private GridLayoutGroup gridLayoutGroup;

		public int Segments
		{
			get
			{
				return _segments;
			}
			set
			{
				_segments = Math.Max(value, 2);
			}
		}

		public void PreInit()
		{
			CreateRecyclingSystem();
			_recyclingSystem.CreateCellPool();
		}

		protected override void Start()
		{
			base.vertical = true;
			base.horizontal = false;
			if (Application.isPlaying && SelfInitialize)
			{
				Initialize();
			}
		}

		private void CreateRecyclingSystem()
		{
			if (Direction == DirectionType.Vertical)
			{
				if (_recyclingSystem == null || !base.vertical)
				{
					_recyclingSystem = new VerticalRecyclingSystem(PrototypeCell, base.viewport, base.content, DataSource, IsGrid, Segments);
				}
			}
			else if (Direction == DirectionType.Horizontal && (_recyclingSystem == null || !base.horizontal))
			{
				_recyclingSystem = new HorizontalRecyclingSystem(PrototypeCell, base.viewport, base.content, DataSource, IsGrid, Segments);
			}
			base.vertical = Direction == DirectionType.Vertical;
			base.horizontal = Direction == DirectionType.Horizontal;
		}

		private void Initialize()
		{
			CreateRecyclingSystem();
			gridLayoutGroup = GetComponentInChildren<GridLayoutGroup>();
			hasGridLayoutGroup = gridLayoutGroup != null;
			_prevAnchoredPos = base.content.anchoredPosition;
			base.onValueChanged.RemoveListener(OnValueChangedListener);
			if ((bool)scrollbar)
			{
				scrollbar.onValueChanged.RemoveListener(OnScrollbarValueChanged);
			}
			StartCoroutine(_recyclingSystem.InitCoroutine(delegate
			{
				base.onValueChanged.AddListener(OnValueChangedListener);
				if ((bool)scrollbar)
				{
					scrollbar.onValueChanged.AddListener(OnScrollbarValueChanged);
				}
			}));
		}

		public void Initialize(IRecyclableScrollRectDataSource dataSource)
		{
			DataSource = dataSource;
			Initialize();
		}

		public void OnValueChangedListener(Vector2 normalizedPos)
		{
			Vector2 direction = base.content.anchoredPosition - _prevAnchoredPos;
			m_ContentStartPosition += _recyclingSystem.OnValueChangedListener(direction);
			_prevAnchoredPos = base.content.anchoredPosition;
			if ((bool)scrollbar)
			{
				int crossAxisCount = _recyclingSystem.CrossAxisCount;
				int num = Mathf.CeilToInt((float)(_recyclingSystem.PoolCount + _recyclingSystem.CrossAxisOffset) / (float)crossAxisCount);
				int num2 = Mathf.CeilToInt((float)_recyclingSystem.CurrentItemCount / (float)crossAxisCount);
				float cellSize = _recyclingSystem.CellSize;
				float contentSize = GetContentSize();
				float num3 = (float)num * cellSize;
				float num4 = (float)num2 * cellSize - num3 + _prevAnchoredPos.y;
				previousScrollAmount = num4 / contentSize;
				if (previousScrollAmount <= 0f && hasGridLayoutGroup)
				{
					gridLayoutGroup.enabled = false;
					gridLayoutGroup.enabled = true;
				}
				scrollbar.value = Mathf.Clamp01(1f - previousScrollAmount);
			}
		}

		private void OnScrollbarValueChanged(float value)
		{
			float num = 1f - value;
			float num2 = num - previousScrollAmount;
			if (!(Mathf.Abs(num2) <= Mathf.Epsilon))
			{
				previousScrollAmount = num;
				float num3 = GetContentSize() * num2;
				Vector2 prevAnchoredPos = _prevAnchoredPos;
				prevAnchoredPos.y += num3;
				SetContentAnchoredPosition(prevAnchoredPos);
				OnValueChangedListener(prevAnchoredPos);
			}
		}

		public float GetCellSize()
		{
			return _recyclingSystem.CellSize;
		}

		public float GetContentSize()
		{
			int crossAxisCount = _recyclingSystem.CrossAxisCount;
			return (float)Mathf.CeilToInt((float)_recyclingSystem.DataSource.GetItemCount() / (float)crossAxisCount) * GetCellSize() - base.viewport.rect.height;
		}

		public float GetScrollPosition()
		{
			return 1f - scrollbar.value;
		}

		public void SetScrollPosition(float value)
		{
			scrollbar.value = Mathf.Clamp01(1f - value);
		}

		public void ReloadData()
		{
			ReloadData(DataSource);
			OnScrollbarValueChanged(1f);
		}

		public void ReloadData(IRecyclableScrollRectDataSource dataSource)
		{
			if (_recyclingSystem != null)
			{
				StopMovement();
				base.onValueChanged.RemoveListener(OnValueChangedListener);
				_recyclingSystem.DataSource = dataSource;
				StartCoroutine(_recyclingSystem.InitCoroutine(delegate
				{
					base.onValueChanged.AddListener(OnValueChangedListener);
				}));
				_prevAnchoredPos = base.content.anchoredPosition;
			}
		}
	}
}
