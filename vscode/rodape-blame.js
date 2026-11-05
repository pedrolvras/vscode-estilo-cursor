// Leva o autor da linha (git blame, "Fulano (1 week ago)") do lado direito do rodapé para o esquerdo,
// logo depois do branch, da sincronização e dos problemas.
// Carregado pelo Custom CSS and JS Loader (vscode_custom_css.imports no settings.json).
(function () {
  var ID = 'vscode.git.git.blame';

  function mover() {
    var item = document.getElementById(ID);
    var esquerda = document.querySelector('.part.statusbar .left-items');
    if (!item || !esquerda) { return; }
    if (item.parentElement !== esquerda || esquerda.lastElementChild !== item) {
      esquerda.appendChild(item);
    }
  }

  // O VS Code recria e reordena o rodapé; observa e move de novo quando precisar
  var obs = new MutationObserver(mover);
  function iniciar() {
    var rodape = document.querySelector('.part.statusbar');
    if (!rodape) { setTimeout(iniciar, 500); return; }
    obs.observe(rodape, { childList: true, subtree: true });
    mover();
  }
  iniciar();
})();
