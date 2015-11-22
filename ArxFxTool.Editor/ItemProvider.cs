using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace ArxFxTool.Editor
{
	public class ItemProvider
	{
		public static List<Item> GetItems(string path)
		{
			var items = new List<Item>();
			var dirInfo = new DirectoryInfo(path);

			foreach (var directory in dirInfo.GetDirectories())
			{
				var item = new DirectoryItem
				{
					Name = directory.Name,
					Path = directory.FullName,
					Items = GetItems(directory.FullName)
				};

				items.Add(item);
			}

			var allowedExtensions = new[] { "fx", "hlsl", "h", "png" };
			foreach (var file in dirInfo.GetFiles())
			{
				if (allowedExtensions.Any(x => file.Extension.EndsWith(x)) == false)
				{
					continue;
				}

				var item = new FileItem
				{
					Name = file.Name,
					Path = file.FullName
				};

				items.Add(item);
			}

			return items;
		}
	}
}