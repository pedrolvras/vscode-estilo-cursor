# Copiar com @ (opcional)

`Ctrl+C` num arquivo (ou em vários) do explorador do VS Code faz a cópia normal e também põe
`@caminho/relativo` na área de transferência (com espaço no caminho, `@"caminho com espaço"`).
`Ctrl+V` no chat cola o texto; ao enviar, a menção vira azul e o arquivo vai anexado.

- Ligar/desligar: botão `@` no rodapé, ou `Ctrl+Shift+P` → "Copiar com @: ligar/desligar"
  (configuração `copiarArroba.ativo`). Desligado, o `Ctrl+C` só copia o arquivo.
- Instalar: `powershell -ExecutionPolicy Bypass -File .\opcional\copiar-arroba\instalar.ps1` e
  recarregar a janela.
- Arrastar para o chat também funciona sem a extensão: segure `Shift` ao soltar.
