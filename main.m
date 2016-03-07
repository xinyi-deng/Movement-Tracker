%In main function, first create game interface. Then define several
%global variables to enable modifications to game interface in another
%function.


    global figure1
    figure1= figure;
    ax1= axes('Parent',figure1,'Position',[0,0,1,1]);
    global ax2
    ax2 = axes('Parent',figure1,'Position',[0,0,0.2,0.2]);
    global ax3
    ax3 = axes('Parent',figure1,'Position',[0.8,0.8,0.1,0.1]);
    set(ax1,'Visible','off');
    set(ax2,'Visible','off');
    set(ax3,'Visible','off');
    
    global a
    global alpha 
    [a,map,alpha]=imread('minion1.png');
    a = imresize(a,0.2);
    alpha = imresize(alpha,0.2);
    global I
    I=imshow(a,'Parent',ax2);
    set(I,'AlphaData',alpha);
    
    global b
    global alpha2
    [b,map2,alpha2]=imread('banana.png');
    b = imresize(b,0.1);
    alpha2 = imresize(alpha2,0.1);
    global II
    II =imshow(b,'Parent',ax3);
    set(II,'AlphaData',alpha2);
    
    imshow('grass.jpg','Parent',ax1);
    
    global lastX
    lastX = 0;
    global lastY
    lastY = 0;
    hold on
    
    
    ready = input('Ready to go?','s');
    while(ready~='y')
        ready = inpnut('Ready to go?','s');
    end
    
    global win
    win = 0;
        

% this function first shows a snapshot of live video. User should 
% select a region to be tracked within the snapshot.
% It then picks up interesting points automatically and 
% tracks these interesting points within live video.
object_tracking