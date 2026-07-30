public abstract class PersistentItemTest<T>
{
	public string ID;

	public string SceneName;

	public T ExpectedValue;

	public abstract bool IsFulfilled { get; }
}
