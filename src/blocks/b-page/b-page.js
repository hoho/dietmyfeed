if (location.hash == '#_=_' && history && history.replaceState) {
    history.replaceState(null, null, location.pathname);
}

$(function() {
    (function(w) {
        w.requestAnimationFrame = w.requestAnimationFrame ||
                                  w.mozRequestAnimationFrame ||
                                  w.webkitRequestAnimationFrame ||
                                  w.msRequestAnimationFrame ||
                                  function(callback) {
                                      w.setTimeout(callback, 0);
                                  };
    })(window);


    $('%b-page(content) .js').bemMod('js', true);
});
