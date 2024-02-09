_  = function(p) return p; end;
name = _('Oggi');
Description = 'Exports right of main screen'
mfdDimension = 500
mfdPadding = 60
secondScreenWidth = 1920
secondScreenHeight = 1080
titlebarHeight = 30
Viewports =
{
     Center =
     {
          x = 0;
          y = 0;
          width = screen.width - secondScreenWidth;
          height = screen.height;
          viewDx = 0;
          viewDy = 0;
          aspect = (screen.width - secondScreenWidth) / screen.height;
     }
}

LEFT_MFCD =
{
     x = screen.width - secondScreenWidth + mfdPadding;
     y = 0 + mfdPadding;
     width = mfdDimension;
     height = mfdDimension;
}

RIGHT_MFCD =
{
     x = screen.width - mfdDimension - mfdPadding;
     y = 0 + mfdPadding;
     width = mfdDimension;
     height = mfdDimension;
}

CENTER_MFCD =
{
     x = screen.width - secondScreenWidth / 2 - mfdDimension / 2;
     y = secondScreenHeight - mfdDimension - mfdPadding - titlebarHeight;
     width = mfdDimension;
     height = mfdDimension;
}

UIMainView = Viewports.Center
GU_MAIN_VIEWPORT = Viewports.Center