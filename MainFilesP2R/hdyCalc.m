function [BRid] = hdyCalc(nPos,nAngle,nSpeed,vid,roadWidth,numOflane,gamma_,betta_,forMaxT,tti,NbeaconsT,NbeaconsF,realTime,refTime,a,b,c,d)
% nPos =[x;y] ,meter
% nAngle : 0 = 12'oclock, 90=3'oclock, degree
% nSpeed : not including direction meter/second
% vid : index of vehicle
% roadWidth =4; %meter
% numOflane =6;%appParams.NbeaconsF;  
% gamma_ =1000;%meter
% betta_ =appParams.NbeaconsT; %==NbeconsT
% forMaxT = appParams.NbeaconsT
% tti = phyParams.TTI
% NbeaconsT = appParams.NbeaconsT
% NbeaconsF = appParams.NbeaconsF
% realTime
% refTime
% a =simValues.spsORp2r(vid), ...
% b = simValues.whenSelectRrc(vid), ...
% c
% d = ResCounter

gamma_=1200;

% change angle : degree to radian
piAngle=mod(90-nAngle,360);
piAngle=(piAngle/180)*pi; %radian

% change speed to velocity
nSpeedVector=[cos(piAngle);sin(piAngle)] *nSpeed;

% theta matrix
thetaMat=[cos(piAngle),sin(piAngle); -1*sin(piAngle),cos(piAngle)];
if (mod(90-nAngle,360)>=180)
    thetaMat=thetaMat*-1;
end

sf=0; %subframe
sc=0; %subchannel
p2rRBid=0;
BRid=-1;


if forMaxT<0
    
    tPos=nPos;
    tPos=thetaMat * tPos;

    numOfResourceInOneLane=floor((NbeaconsT*NbeaconsF)/numOflane);
    lengthOneSegmant=gamma_/numOfResourceInOneLane;
    tx=floor(mod(tPos(1),gamma_) /lengthOneSegmant);
    ty=floor(mod(tPos(2),roadWidth*numOflane)/roadWidth);
    p2rRBid=numOflane*tx+ty+1;
    
    
    sf=ceil(p2rRBid/NbeaconsF); %mod(p2rRBid,betta_);
    sc=mod(p2rRBid-1,NbeaconsF)+1; %floor(p2rRBid/betta_);

%     if vid==83 || vid==95
    fprintf("\n=====sent=======t(%f),vID(%d),BRid(nowCal=%d => %d)=(tf=%d,%d) ResCounter(%d),Rtype(%d),when(%f),pos(%f,%f=>%f,%f),angle(%f),\tspeed(%f),-------------------------------------\n", ...
                realTime, ...
                vid, ...
                p2rRBid, c,...
                sf,sc, ...
                d, ...
                a,b, ...
                nPos(1),nPos(2),tPos(1),tPos(2), ...
                nAngle, nSpeed);
%     end

else
    for i=1:forMaxT %unit is millisecond
        tPos=nPos + nSpeedVector*i*tti; 
        dddd=nPos + nSpeedVector*i*tti; 
        tPos=thetaMat * tPos;

        numOfResourceInOneLane=floor((NbeaconsT*NbeaconsF)/numOflane);
        lengthOneSegmant=gamma_/numOfResourceInOneLane;
        tx=floor(mod(tPos(1),gamma_) /lengthOneSegmant);
        ty=floor(mod(tPos(2),roadWidth*numOflane)/roadWidth);
        p2rRBid=numOflane*tx+ty+1;
        sf=ceil(p2rRBid/NbeaconsF); %mod(p2rRBid,betta_);
        sc=mod((p2rRBid)-1,NbeaconsF)+1; %floor(p2rRBid/betta_);
        
                %         fprintf("\n v(%d) t(%f+%d=%f) ang(%d) pos(%f,%f => %f,%f) txty=(%f,%f) RBid=%d sf,sc=(%f,%f)----------------------------------------", ...
                %             scheduledID(indexSensingV), timeManagement.elapsedTime_TTIs,i,timeManagement.elapsedTime_TTIs+i, ...
                %             nAngle,dddd(1), dddd(2), tPos(1),tPos(2), ...
                %             tx,ty,p2rRBid,sf,sc);
        futureT = mod(refTime+i-1,betta_)+1; 
        if abs(futureT - sf)<0.000001

%              if vid==83 || vid==95
               if forMaxT ~=1000000
                fprintf("\nvID(%d),t(%f+%d=%f),BRid+1(%d),sf+sc=(%f,%f),pos(%f,%f=>%f,%f=> %f,%f), angle(%f),speed(%f),  \ttxty=(%f,%f),-------------------------------------\n", ...
                    vid, refTime,i,futureT, ...
                    p2rRBid,sf,sc, ...
                    nPos(1),nPos(2),dddd(1), dddd(2),tPos(1),tPos(2), ...
                    nAngle,nSpeed,...
                    tx,ty);
%              end
%                else
%                  fprintf("\n_____recalculate_____vID(%d),t(%f+%d=%f),BRid+1(%d),sf+sc=(%f,%f),pos(%f,%f=>%f,%f=> %f,%f), angle(%f),speed(%f),  \ttxty=(%f,%f),-------------------------------------\n", ...
%                     vid, refTime,i,futureT, ...
%                     p2rRBid,sf,sc, ...
%                     nPos(1),nPos(2),dddd(1), dddd(2),tPos(1),tPos(2), ...
%                     nAngle,nSpeed,...
%                     tx,ty);
               end
            BRid=p2rRBid;
            break;
        end
    end
    if BRid==-1
        if forMaxT ~=1000000
                    fprintf("\nvID(%d),XXXXXXXXXX t(%f+%d), pos(%f,%f=>???), angle(%f),speed(%f), BRid+1(%d)-------------------------------------\n", ...
                    vid, refTime,forMaxT, ...
                    nPos(1),nPos(2), ...
                    nAngle,nSpeed,...
                    p2rRBid);
%         else
%             printf("\n_____recalculate_____vID(%d),XXXXXXXXXX t(%f+%d), pos(%f,%f=>???), angle(%f),speed(%f), BRid+1(%d)-------------------------------------\n", ...
%                     vid, refTime,forMaxT, ...
%                     nPos(1),nPos(2), ...
%                     nAngle,nSpeed,...
%                     p2rRBid);
        end
    end
end


