# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Chocolatey Modules
$chocoPackages = @(
    'azure-cli',
    'docker-for-windows',
    'git'
    'kubernetes-cli',
    'kubernetes-helm',
    'minikube',
    'poshgit',
    'terraform',
    'vscode'
)

$chocoPackages | ForEach-Object {choco install $_ -y}

# Install vscode Extensions
$codeExtensions = @(
    'be5invis.vscode-custom-css',
    'CoenraadS.bracket-pair-colorizer-2',
    'DavidAnson.vscode-markdownlint',
    'eamodio.gitlens',
    'esbenp.prettier-vscode',
    'mauve.terraform',
    'mohsen1.prettify-json',
    'ms-azuretools.vscode-azureterraform',
    'ms-azuretools.vscode-docker',
    'ms-kubernetes-tools.vscode-kubernetes-tools',
    'ms-vscode.azure-account',
    'ms-vscode.azurecli',
    'ms-vscode.powershell',
    'ms-vsliveshare.vsliveshare',
    'redhat.vscode-yaml',
    'RobbOwen.synthwave-vscode',
    'shd101wyy.markdown-preview-enhanced',
    'stuart.unique-window-colors',
    'ybaumes.highlight-trailing-white-spaces'
)

$codeExtensions | ForEach-Object {code --install-extension $_}

$codeSettings = Get-Content "$env:APPDATA\Code\User\settings.json" | ConvertFrom-Json
$codeSettings.'workbench.colorTheme' = 'Abyss'
$codeSettings | ConvertTo-Json | Set-Content "$env:APPDATA\Code\User\settings.json"