% in this function, I'll create a GUI interface, showing basic game rules
% and displaying a movable character
% At first, it will display an empty canvas. Once position is got from the
% object being tracked, it will automatically create a character at the
% given position on the empty canvas. And position of character will keep
% being update as new values are read in.
function gui_interface(factor)
    global win
    if win==1
        return
    end
    global I
    global ax2
    global figure1
    global alpha
    global a  
    global lastX
    global lastY
    delete(I)
    adjust = 0.1;
    newX = lastX-factor(1)*adjust;
    %newX = lastX+factor(1)*adjust;
    newY = lastY-factor(2)*adjust;
    if newX<0
        newX=0;
    end
    if newY<0
        newY=0;
    end
    
    if newX>1
        newX = 1;
    end
    
    if newY>1
        newY=1;
    end
    lastX = newX;
    lastY = newY;
    ax2 = axes('Parent',figure1,'Position',[newX,newY,0.2,0.2]);
    I=imshow(a,'Parent',ax2);
    set(I,'AlphaData',alpha);
    if newX>=0.65 && newY >= 0.7 && newX<=0.75 && newY<=0.8
        win = 1;
        disp('YOU WIN!')
    end
        
        
        
    
    