# Copiar com @ (opcional)

`Ctrl+C` num arquivo (ou em vários) do explorador do VS Code faz a cópia normal e também põe
`@caminho/relativo` na área de transferência (com espaço no caminho, `@"caminho com espaço"`).
`Ctrl+V` no chat do Claude Code com só menções na área de transferência põe cada uma no chat em azul
(como escolhida pelo `@`): a extensão abre o arquivo, usa o comando "Insert @-Mention Reference" do
Claude Code (`Alt+K`) e fecha a aba se ela não estava aberta (por isso a tela pisca). Qualquer outra
coisa (texto, imagem) cola normalmente.

- Ligar/desligar: botão `@` no rodapé, ou `Ctrl+Shift+P` → "Copiar com @: ligar/desligar"
  (configuração `copiarArroba.ativo`). Desligado, o `Ctrl+C` e o `Ctrl+V` voltam ao normal.
- Instalar: `powershell -ExecutionPolicy Bypass -File .\opcional\copiar-arroba\instalar.ps1` e
  recarregar a janela.
- Arrastar para o chat também funciona sem a extensão: segure `Shift` ao soltar.
