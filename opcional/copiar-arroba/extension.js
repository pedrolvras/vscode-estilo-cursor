// Ctrl+C no explorador: copia o arquivo como sempre e, se ligado:
// - põe "@caminho/relativo" na área de transferência (um por arquivo, separados por espaço; entre aspas
//   quando o caminho tem espaço), para colar em qualquer lugar;
// - manda a menção direto para o chat do Claude Code (em azul, como escolhida pelo @), pelo comando
//   "Insert @-Mention Reference" (Alt+K) do Claude Code.
const vscode = require('vscode');

function ativo() {
  return vscode.workspace.getConfiguration('copiarArroba').get('ativo', true);
}

function atualizar(item) {
  if (ativo()) {
    item.text = '@';
    item.tooltip = 'Copiar com @: ligado (Ctrl+C no explorador menciona o arquivo no chat). Clique para desligar.';
    item.color = undefined;
  } else {
    item.text = '$(circle-slash) @';
    item.tooltip = 'Copiar com @: desligado (Ctrl+C copia só o arquivo). Clique para ligar.';
    item.color = new vscode.ThemeColor('disabledForeground');
  }
}

// caminho relativo do copyRelativeFilePath -> Uri de arquivo (com várias pastas abertas, o caminho
// pode vir com o nome da pasta na frente); pasta ou inexistente -> null
async function acharUri(rel) {
  const pastas = vscode.workspace.workspaceFolders || [];
  for (const pasta of pastas) {
    const candidatos = [rel];
    if (rel.indexOf(pasta.name + '/') === 0) { candidatos.push(rel.substring(pasta.name.length + 1)); }
    for (const c of candidatos) {
      const uri = vscode.Uri.joinPath(pasta.uri, c);
      try {
        const st = await vscode.workspace.fs.stat(uri);
        if (st.type & vscode.FileType.File) { return uri; }
      } catch (e) { /* não existe nesta pasta */ }
    }
  }
  return null;
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
    const caminhos = texto.split(/\r?\n/)
      .map(function (p) { return p.trim().split(String.fromCharCode(92)).join('/'); })
      .filter(function (p) { return p !== ''; });
    if (!caminhos.length) { return; }
    const mencoes = caminhos.map(function (p) { return /\s/.test(p) ? '@"' + p + '"' : '@' + p; });
    await vscode.env.clipboard.writeText(mencoes.join(' ') + ' ');

    // O comando do Claude Code usa o arquivo aberto no editor: abre cada um (sem seleção, para
    // mencionar o arquivo inteiro), manda a menção e volta ao editor de antes.
    const anterior = vscode.window.activeTextEditor;
    let azuis = 0;
    for (const rel of caminhos) {
      const uri = await acharUri(rel);
      if (!uri) { continue; }
      try {
        const doc = await vscode.workspace.openTextDocument(uri);
        await vscode.window.showTextDocument(doc, { preview: true, preserveFocus: false, selection: new vscode.Range(0, 0, 0, 0) });
        await vscode.commands.executeCommand('claude-vscode.insertAtMention');
        azuis++;
      } catch (e) {
        // imagem, binário ou Claude Code ausente: fica só o texto copiado
      }
    }
    if (anterior && azuis > 0) {
      await vscode.window.showTextDocument(anterior.document, { viewColumn: anterior.viewColumn, preserveFocus: true, selection: anterior.selection });
    }
    vscode.window.setStatusBarMessage((azuis > 0 ? 'Mencionado no chat: ' : 'Copiado: ') + mencoes.join(' '), 2500);
  }));
}

function deactivate() {}

module.exports = { activate: activate, deactivate: deactivate };
