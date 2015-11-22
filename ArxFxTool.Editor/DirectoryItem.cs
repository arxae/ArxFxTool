using System.Collections.Generic;

namespace ArxFxTool.Editor
{
	public class DirectoryItem : Item
	{
		public List<Item> Items { get; set; }

		public DirectoryItem()
		{
			Items = new List<Item>();
		}
	}
}