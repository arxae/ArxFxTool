using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace ArxFxTool
{
	public class ArxFxConfig
	{
		public Dictionary<string, string> Uncategorized { get; set; }
		public Dictionary<string, bool> Toggles { get; set; }

		public ArxFxConfig()
		{
			Uncategorized = new Dictionary<string, string>();
			Toggles = new Dictionary<string, bool>();
		}

		public static ArxFxConfig ReadConfig()
		{
			List<string> lines = File.ReadAllLines("ArxFx/ArxFxContent/ArxFx.h").ToList();
			var cfg = new ArxFxConfig();

			foreach (var line in lines)
			{
				if (line.StartsWith("//")) // Skip comments
				{
					continue;
				}

				if (line.StartsWith("#define"))
				{
					var split = line.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);

					var def = new Tuple<string, string>(split[1], split[2]);

					switch (def.Item1.ToLower())
					{
						case "use_swfx_technicolor":
							cfg.Toggles.Add("Use Technicolor", Util.ParseBool(def.Item2));
							break;
						case "use_dpx":
							cfg.Toggles.Add("Use DPX", Util.ParseBool(def.Item2));
							break;
						case "use_vibrance":
							cfg.Toggles.Add("Use Vibrance", Util.ParseBool(def.Item2));
							break;
						case "use_crossprocess":
							cfg.Toggles.Add("Use Crossprocess", Util.ParseBool(def.Item2));
							break;
						case "use_lensdirt":
							cfg.Toggles.Add("Use Lensdirt", Util.ParseBool(def.Item2));
							break;
						case "use_bloom":
							cfg.Toggles.Add("Use Bloom", Util.ParseBool(def.Item2));
							break;
						case "use_vignette":
							cfg.Toggles.Add("Use Vignette", Util.ParseBool(def.Item2));
							break;
						case "use_adpsharpening":
							cfg.Toggles.Add("Use Sharpening", Util.ParseBool(def.Item2));
							break;
						default:
							cfg.Uncategorized.Add(def.Item1, def.Item2);
							break;
					}
				}
			}

			return cfg;
		}
	}

	public static class Util
	{
		public static bool ParseBool(string text)
		{
			return text == "1";
		}
	}
}
