using System.Windows;
using Ookii.Dialogs.Wpf;

namespace ArxFxTool
{
	public partial class MainWindow
	{
		public bool Is64Bit { get; set; }
		public string ExePath { get; set; }

		public MainWindow()
		{
			InitializeComponent();
		}

		private void BrowseButton_Click(object sender, RoutedEventArgs e)
		{
			var dialog = new VistaOpenFileDialog
			{
				Filter = "Executables (*.exe)|*.exe",
				Multiselect = false
			};

			if (dialog.ShowDialog() == true)
			{
				ExePathTextBox.Text = dialog.FileName;
				ExePath = dialog.FileName;
			}
		}

		private void WindowCommand_About_Click(object sender, RoutedEventArgs e)
		{
			Menu.IsOpen = !Menu.IsOpen;
		}

		private void Menu_EditShaderCode(object sender, RoutedEventArgs e)
		{
			new Editor.MainWindow().Show();
		}

		private void DeployButton(object sender, RoutedEventArgs e)
		{
			if (string.IsNullOrWhiteSpace(ExePath) == false)
			{
				DeploymentManager.DeployTo(ExePath, GetGraphicsApiSelection(), Is64Bit);
			}
		}

		private GraphicsApi GetGraphicsApiSelection()
		{
			if ((bool)API_DX8.IsChecked)
			{
				return GraphicsApi.DirectX8;
			}

			if ((bool)API_DX9.IsChecked)
			{
				return GraphicsApi.DirectX9;
			}

			if ((bool)API_DX10.IsChecked)
			{
				return GraphicsApi.DirectX10;
			}

			if ((bool)API_DX11.IsChecked)
			{
				return GraphicsApi.DirectX11;
			}

			if ((bool)API_OGL.IsChecked)
			{
				return GraphicsApi.OpenGL;
			}

			return GraphicsApi.Unknown;
		}
	}
}