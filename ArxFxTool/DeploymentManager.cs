using System;
using System.Collections.Generic;
using System.IO;

namespace ArxFxTool
{
	public class DeploymentManager
	{
		public static GraphicsApi _graphicsApi;

		public static void DeployTo(string exePath, GraphicsApi gapi, bool is64bit)
		{
			string path = Path.GetDirectoryName(exePath);
			string fxFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ArxFx", "ReShade.fx");
			List<CopyDef> files = GetIncludedFiles(fxFile);
			files.Add(new CopyDef(fxFile, "ReShade.fx"));

			string reshadeDllPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ArxFx", "ReShade{0}.dll");

			if (gapi == GraphicsApi.Unknown)
			{
				var apis = GetAllGraphicsApiList();

				foreach (var api in apis)
				{
					files.Add(new CopyDef(
						string.Format(reshadeDllPath, is64bit ? "64" : "32"),
						api
					));
				}
			}
			else
			{
				files.Add(new CopyDef(
					string.Format(reshadeDllPath, is64bit ? "64" : "32"),
					GetGraphicsApiDll(gapi)
				));
			}

			CopyFiles(files, path);
		}

		private static List<CopyDef> GetIncludedFiles(string path)
		{
			var lines = File.ReadAllLines(path);
			var copyList = new List<CopyDef>();
			foreach (var line in lines)
			{
				if (!line.StartsWith("#include")) continue;

				string[] split = line.Split(' ');
				var includepath = Path.Combine(Path.GetDirectoryName(path), split[1].Replace("\"", ""));

				if (File.Exists(includepath))
				{
					copyList.Add(new CopyDef(includepath, split[1].Replace("\"", "")));
				}
			}

			return copyList;
		}

		private static void CopyFiles(List<CopyDef> files, string destinationFolder)
		{
			foreach (var file in files)
			{
				var destination = Path.Combine(destinationFolder, file.Destination);
				var folder = Path.GetDirectoryName(destination);

				if (Directory.Exists(folder) == false)
				{
					Directory.CreateDirectory(folder);
				}

				File.Copy(file.Source, destination, true);
			}

		}

		public static string GetGraphicsApiDll(GraphicsApi api)
		{
			switch (api)
			{
				case GraphicsApi.DirectX8: return "d3d8.dll";
				case GraphicsApi.DirectX9: return "d3d9.dll";
				case GraphicsApi.DirectX10: return "dxgi.dll";
				case GraphicsApi.DirectX11: return "dxgi.dll";
				case GraphicsApi.OpenGL: return "opengl32.dll";
				default:
					throw new ArgumentOutOfRangeException(nameof(api), api, null);
			}
		}

		public static List<string> GetAllGraphicsApiList()
		{
			return new List<string>
			{
				"d3d8.dll",
				"d3d9.dll",
				"dxgi.dll",
				"opengl32.dll"
			};
		}

		public class CopyDef
		{
			public string Source;
			public string Destination;

			public CopyDef(string s, string d)
			{
				Source = s;
				Destination = d;
			}
		}
	}
}
