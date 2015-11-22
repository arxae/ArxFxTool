using System;
using System.Collections.Generic;
using System.IO;
using System.Windows;
using System.Xml;
using System.Windows.Controls;
using ICSharpCode.AvalonEdit.Highlighting;
using ICSharpCode.AvalonEdit.Indentation;
using ICSharpCode.AvalonEdit.Highlighting.Xshd;
using Ookii.Dialogs.Wpf;

using MahApps.Metro.Controls.Dialogs;

namespace ArxFxTool.Editor
{
	public partial class MainWindow
	{
		public List<Item> Items;

		public MainWindow()
		{
			InitializeComponent();
			CodeEditor.TextArea.IndentationStrategy = new DefaultIndentationStrategy();

			string xshdPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "hlsl.xshd");
			using (Stream s = File.OpenRead(xshdPath))
			{
				using (XmlTextReader reader = new XmlTextReader(s))
				{
					CodeEditor.SyntaxHighlighting = HighlightingLoader.Load(reader, HighlightingManager.Instance);
				}
			}
		}

		private void MenuButton_Click(object sender, System.Windows.RoutedEventArgs e)
		{
			Menu.IsOpen = true;
		}

		private void OpenAFXFolderMenuItem_Click(object sender, System.Windows.RoutedEventArgs e)
		{
			var ofd = new VistaOpenFileDialog
			{
				Filter = "ReShade.fx|Reshade.fx"
			};

			if (ofd.ShowDialog() == true)
			{
				string fxpath = ofd.FileName;
				Items = ItemProvider.GetItems(Path.GetDirectoryName(fxpath));

				// Reset the datacontext
				DataContext = null;
				DataContext = Items;
			}
		}

		private void FileTree_DoubleClick(object sender, System.Windows.Input.MouseButtonEventArgs e)
		{
			if (((TreeView)sender).SelectedItem.GetType() != typeof(FileItem))
			{
				return;
			}

			FileItem file = (FileItem)((TreeView)sender).SelectedItem;
			if (file != null)
			{
				LoadTextIntoEditor(file.Path);
			}
		}

		private void LoadTextIntoEditor(string path)
		{
			CodeEditor.Text = "";
			var text = File.ReadAllText(path);
			CodeEditor.Text = text;
		}

		private void MenuExitButton(object sender, RoutedEventArgs e)
		{
			Application.Current.Shutdown(0);
		}

		private void MenuNewButton(object sender, RoutedEventArgs e)
		{
			if (NewItemMenu.IsOpen == false)
			{
				NewFileName.Text = "";
			}

			NewItemMenu.IsOpen = !NewItemMenu.IsOpen;
		}

		private void CreateNewFileOkButton(object sender, RoutedEventArgs e)
		{
			NewItemMenu.IsOpen = false;
		}
	}
}