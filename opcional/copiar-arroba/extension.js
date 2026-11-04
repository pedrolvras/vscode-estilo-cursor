// Ctrl+C no explorador: copia o arquivo como sempre e, se ligado, põe "@caminho/relativo" na área de
// transferência (um por arquivo, separados por espaço), para colar no chat do Claude Code.
const vscode = require('vscode');

function ativo() {
  return vscode.workspace.getConfiguration('copiarArroba').get('ativo', true);
}

function atualizar(item) {
  if (ativo()) {
    item.text = '@';
    item.tooltip = 'Copiar com @: ligado (Ctrl+C no explorador copia @caminho). Clique para desligar.';
    item.color = undefined;
  } else {
    item.text = '$(circle-slash) @';
    item.tooltip = 'Copiar com @: desligado (Ctrl+C copia só o arquivo). Clique para ligar.';
    item.color = new vscode.ThemeColor('disabledForeground');
  }
}

function activate(context) {
  const item = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  item.command = 'copiarArroba.alternar';
  atualizar(item);
  item.show();
  context.subscriptions.push(item);

  context.subscriptions.push(vscode.workspace.onDidChangeConfiguration(function (e) {
    if (e.affectsConfiguration('copiarArroba.ativo')) { atualizar(item); }
  }));

  context.subscriptions.push(vscode.commands.registerCommand('copiarArroba.alternar', async function () {
    await vscode.workspace.getConfiguration('copiarArroba').update('ativo', !ativo(), vscode.ConfigurationTarget.Global);
    vscode.window.setStatusBarMessage(ativo() ? 'Copiar com @: ligado' : 'Copiar com @: desligado', 2000);
  }));

  context.subscriptions.push(vscode.commands.registerCommand('copiarArroba.copiar', async function () {
    if (!ativo()) {
      await vscode.commands.executeCommand('filesExplorer.copy');
      return;
    }
    // caminhos relativos da seleção do explorador (um por linha)
    await vscode.commands.executeCommand('copyRelativeFilePath');
    const texto = await vscode.env.clipboard.readText();
    await vscode.commands.executeCommand('filesExplorer.copy');
    const mencoes = texto.split(/\r?\n/)
      .map(function (p) { return p.trim().split(String.fromCharCode(92)).join('/'); })
      .filter(function (p) { return p !== ''; })
      .map(function (p) { return '@' + p; });
    if (mencoes.length) {
      await vscode.env.clipboard.writeText(mencoes.join(' ') + ' ');
      vscode.window.setStatusBarMessage('Copiado: ' + mencoes.join(' '), 2500);
    }
  }));
}

function deactivate() {}

module.exports = { activate: activate, deactivate: deactivate };
