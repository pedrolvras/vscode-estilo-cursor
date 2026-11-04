// Copiar com @
// - Ctrl+C no explorador: copia o arquivo como sempre e, se ligado, põe "@caminho/relativo" na área de
//   transferência (um por arquivo, separados por espaço; entre aspas quando o caminho tem espaço).
// - Ctrl+V no chat do Claude Code: se a área de transferência tem só menções (@caminho), cada uma entra
//   no chat em azul, pelo comando "Insert @-Mention Reference" (Alt+K) do Claude Code; qualquer outra
//   coisa (texto, imagem) cola normalmente.
const vscode = require('vscode');

function ativo() {
  return vscode.workspace.getConfiguration('copiarArroba').get('ativo', true);
}

function atualizar(item) {
  if (ativo()) {
    item.text = '@';
    item.tooltip = 'Copiar com @: ligado (Ctrl+C no explorador copia @caminho; Ctrl+V no chat vira menção). Clique para desligar.';
    item.color = undefined;
  } else {
    item.text = '$(circle-slash) @';
    item.tooltip = 'Copiar com @: desligado (Ctrl+C e Ctrl+V normais). Clique para ligar.';
    item.color = new vscode.ThemeColor('disabledForeground');
  }
}

// caminho relativo -> Uri de arquivo (com várias pastas abertas, o caminho pode vir com o nome da
// pasta na frente); pasta ou inexistente -> null
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

// "@a @\"b c\"" -> ['a', 'b c']; texto que não é só menções -> null
function lerMencoes(texto) {
  const t = String(texto || '').trim();
  if (t === '' || !/^(@"[^"]+"|@[^\s"]+)(\s+(@"[^"]+"|@[^\s"]+))*$/.test(t)) { return null; }
  const re = /@"([^"]+)"|@([^\s"]+)/g;
  const lista = [];
  let m;
  while ((m = re.exec(t)) !== null) { lista.push(m[1] !== undefined ? m[1] : m[2]); }
  return lista;
}

function abaAberta(uri) {
  for (const grupo of vscode.window.tabGroups.all) {
    for (const aba of grupo.tabs) {
      if (aba.input && aba.input.uri && aba.input.uri.toString() === uri.toString()) { return aba; }
    }
  }
  return null;
}

async function colarNormal() {
  await vscode.commands.executeCommand('editor.action.clipboardPasteAction');
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
      .map(function (p) { return /\s/.test(p) ? '@"' + p + '"' : '@' + p; });
    if (mencoes.length) {
      await vscode.env.clipboard.writeText(mencoes.join(' ') + ' ');
      vscode.window.setStatusBarMessage('Copiado: ' + mencoes.join(' '), 2500);
    }
  }));

  context.subscriptions.push(vscode.commands.registerCommand('copiarArroba.colar', async function () {
    const texto = await vscode.env.clipboard.readText();
    const caminhos = ativo() ? lerMencoes(texto) : null;
    if (!caminhos) { await colarNormal(); return; }
    const uris = [];
    for (const rel of caminhos) {
      const uri = await acharUri(rel);
      if (!uri) { await colarNormal(); return; }
      uris.push(uri);
    }
    // O comando do Claude Code usa o arquivo aberto no editor: abre cada um (sem seleção, para
    // mencionar o arquivo inteiro), manda a menção e fecha a aba se ela não estava aberta antes.
    try {
      for (const uri of uris) {
        const jaAberta = abaAberta(uri) !== null;
        const doc = await vscode.workspace.openTextDocument(uri);
        await vscode.window.showTextDocument(doc, { preview: true, preserveFocus: false, selection: new vscode.Range(0, 0, 0, 0) });
        await vscode.commands.executeCommand('claude-vscode.insertAtMention');
        if (!jaAberta) {
          const aba = abaAberta(uri);
          if (aba) { await vscode.window.tabGroups.close(aba, true); }
        }
      }
    } catch (e) {
      // imagem, binário ou Claude Code ausente: cola o texto
      await colarNormal();
    }
  }));
}

function deactivate() {}

module.exports = { activate: activate, deactivate: deactivate };
