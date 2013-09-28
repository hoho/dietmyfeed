$(function() {
    var wnd = $(window),
        abs = Math.abs,
        deltaX,
        coverImgWrapper = $('#b-page__cover div'),
        coverImg = coverImgWrapper.find('img'),
        coverImgHeight,
        coverImgWrapperStyle = coverImgWrapper[0].style,
        curX = 0,
        curY = 0,
        dirX = 1,
        dirY = 1,
        imgX = 0,
        imgY = 0,
        stepX = screen.availWidth / 200,
        stepY = screen.availHeight / 300,

        moveCover = function(pageX, pageY) {
            if (!coverImgHeight) {
                coverImgHeight = coverImg.height();
            }

            var changed,
                moveHeight = Math.ceil(coverImgHeight / 2) - 100,
                step = pageX - curX;

            if (!deltaX) {
                deltaX = 6 / (wnd.width() * 0.06);
                if (isNaN(deltaX)) {
                    deltaX = 0.1;
                }
            }

            if (abs(step) > stepX) {
                imgX += dirX * (step < 0 ? deltaX : -deltaX);

                if (abs(imgX) > 3) {
                    dirX *= -1;
                    imgX = imgX > 0 ? 3 : -3;
                }

                curX = pageX;

                changed = true;
            }

            step = pageY - curY;

            if (abs(step) > stepY) {
                imgY += dirY * (step < 0 ? 1 : -1);

                if (abs(imgY) > moveHeight) {
                    dirY *= -1;
                    imgY = imgY > 0 ? moveHeight : -moveHeight;
                }

                curY = pageY;

                changed = true;
            }

            if (changed) {
                window.requestAnimationFrame(function() {
                    coverImgWrapperStyle.left = -3 + imgX + '%';
                    coverImgWrapperStyle.top = -1000 + imgY + 'px';
                });
            }
        };

    $('body')
        .on('mousemove',
            function(e) {
                moveCover(e.pageX, e.pageY);
            });

    wnd
        .on('resize',
            function() {
                deltaX = coverImgHeight = 0;
                moveCover(curX + stepX + 1, curY + stepY + 1);
            });
});
