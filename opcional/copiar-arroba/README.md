# Copiar com @ (opcional)

`Ctrl+C` num arquivo (ou em vários) do explorador do VS Code faz a cópia normal e também põe
`@caminho/relativo` na área de transferência (com espaço no caminho, `@"caminho com espaço"`, o formato que o chat anexa); `Ctrl+V` no chat do Claude Code cola a menção.

- Com o Claude Code aberto, a menção já entra no chat em azul (como escolhida pelo `@`): a extensão abre
  o arquivo, usa o comando "Insert @-Mention Reference" do Claude Code (`Alt+K`) e volta ao editor de
  antes. Imagem ou pasta fica só como texto na área de transferência.
- Ligar/desligar: botão `@` no rodapé, ou `Ctrl+Shift+P` → "Copiar com @: ligar/desligar"
  (configuração `copiarArroba.ativo`). Desligado, o `Ctrl+C` só copia o arquivo.
- Instalar: `powershell -ExecutionPolicy Bypass -File .\opcional\copiar-arroba\instalar.ps1` e
  recarregar a janela.
- Arrastar para o chat também funciona sem a extensão: segure `Shift` ao soltar.
