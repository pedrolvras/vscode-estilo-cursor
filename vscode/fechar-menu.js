// Fecha o menu (File, Edit... e o do botão direito) quando o mouse sai dele, sem clicar nem apertar Esc.
// Carregado pelo Custom CSS and JS Loader (vscode_custom_css.imports no settings.json).
(function () {
  var ESPERA = 200; // ms fora do menu antes de fechar (dá tempo de passar para um submenu)
  var MENU = '.menubar-menu-items-holder, .context-view, .menubar .menubar-menu-button';
  var timer = null;

  function menuAberto() {
    return document.querySelector('.menubar-menu-items-holder, .context-view .monaco-menu-container, .context-view .shadow-root-host') !== null;
  }

  function focoReal() {
    var a = document.activeElement;
    while (a && a.shadowRoot && a.shadowRoot.activeElement) { a = a.shadowRoot.activeElement; }
    return a || document.body;
  }

  function fechar() {
    timer = null;
    // Cada Esc fecha um nível (submenu, depois o menu): repete até não sobrar nenhum aberto
    for (var i = 0; i < 5 && menuAberto(); i++) { esc(); }
  }

  function esc() {
    var ev = new KeyboardEvent('keydown', { key: 'Escape', code: 'Escape', bubbles: true, cancelable: true, composed: true });
    Object.defineProperty(ev, 'keyCode', { get: function () { return 27; } });
    Object.defineProperty(ev, 'which', { get: function () { return 27; } });
    focoReal().dispatchEvent(ev);
  }

  function aoMover(e) {
    var dentro = e.target && e.target.closest && e.target.closest(MENU);
    if (dentro) {
      if (timer) { clearTimeout(timer); timer = null; }
    } else if (!timer && menuAberto()) {
      timer = setTimeout(fechar, ESPERA);
    }
  }
  // O editor de código nem sempre gera "mouseover"; o movimento do ponteiro pega todas as áreas
  ['mouseover', 'mousemove', 'pointermove'].forEach(function (tipo) {
    window.addEventListener(tipo, aoMover, true);
  });
})();
