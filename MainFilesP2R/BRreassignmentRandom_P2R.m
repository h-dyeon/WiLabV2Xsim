function [BRid, Nreassign] = BRreassignmentRandom_P2R(T1,T2,IDvehicle,simParams,timeManagement,sinrManagement,stationManagement,phyParams,appParams,positionManagement,simValues) % hdy add ,positionManagement,simValues);
% Benchmark Algorithm 101 (RANDOM ALLOCATION)

% T1 and T2 set the time budget
if T1==-1
    T1=1;
end
if T2==-1
    T2=appParams.NbeaconsT;
end
% Was simParams.T1autonomousModeTTIs, simParams.T2autonomousModeTTIs

Nvehicles = length(IDvehicle(:,1));   % Number of vehicles      

% This part considers various limitations
BRid = zeros(length(IDvehicle(:,1)),1);
% A cycle over the vehicles is needed
for idV=1:Nvehicles
    if stationManagement.vehicleState(IDvehicle(idV))~=100
        continue;
    end
    
    status=true;
    while BRid(idV)==0
        
        if status % at first select resource by P2R
                %position information
                nPos=[positionManagement.XvehicleReal(IDvehicle(idV)); ...
                    positionManagement.YvehicleReal(IDvehicle(idV))];
                nSpeed=simValues.v(IDvehicle(idV)); %m/s
                nAngle=simValues.angle(IDvehicle(idV));  %degree
                piAngle=mod(90-nAngle,360);
                piAngle=(piAngle/180)*pi; %radian

                % config parameter
                roadWidth=4; %meter
                numOflane=appParams.NbeaconsF;  
                gamma_=1000;%meter
                betta_=appParams.NbeaconsT; %==NbeconsT
                thetaMat=[cos(piAngle),sin(piAngle); -1*sin(piAngle),cos(piAngle)];
                if(sin(piAngle)<0)
                    thetaMat=thetaMat*-1;
                end

                sf=0; %subframe
                sc=0; %subchannel
                p2rRBid=0;
                for i=1:appParams.NbeaconsT %unit is millisecond
                    tPos=nPos + nSpeed*i*phyParams.TTI; %%%%%%%%%%%%%%%%%%%%%%%%%%%
                    dddd=nPos + nSpeed*i*phyParams.TTI;
                    tPos=thetaMat * tPos;

                    numOfResourceInOneLane=floor(appParams.Nbeacons/numOflane);
                    lengthOneSegmant=gamma_/numOfResourceInOneLane;
                    tx=floor(mod(tPos(1),gamma_) /lengthOneSegmant);
                    ty=floor(mod(tPos(2),roadWidth*numOflane)/roadWidth);
                    p2rRBid=numOflane*tx+ty;
                    sf=mod(p2rRBid,betta_);
                    sc=floor(p2rRBid/betta_);

            %         fprintf("\n v(%d) t(%f+%d=%f) ang(%d) pos(%f,%f => %f,%f) txty=(%f,%f) RBid=%d sf,sc=(%f,%f)----------------------------------------", ...
            %             scheduledID(indexSensingV), timeManagement.elapsedTime_TTIs,i,timeManagement.elapsedTime_TTIs+i, ...
            %             nAngle,dddd(1), dddd(2), tPos(1),tPos(2), ...
            %             tx,ty,p2rRBid,sf,sc);

                    subframeLastPacket = mod(ceil(timeManagement.timeLastPacket(IDvehicle(idV))/phyParams.TTI)-1,(appParams.NbeaconsT))+1;
                    futureT = mod(subframeLastPacket+i-1,betta_)+1; 
                    if abs(futureT - (sf+1))<0.000001
            %             fprintf("\n v(%d)\tt(%f+%d=%f)\tang(%d)\tpos(%f,%f => %f,%f)\ttxty=(%f,%f)\tRBid=%d\tsf,sc=(%f,%f)----------------------------------------", ...
            %             scheduledID(indexSensingV), timeManagement.elapsedTime_TTIs,i,timeManagement.elapsedTime_TTIs+i, ...
            %             nAngle,dddd(1), dddd(2), tPos(1),tPos(2), ...
            %             tx,ty,p2rRBid,sf,sc);
                        BRid(idV)=p2rRBid+1;
                        break;
                    end
                end
            status=false
        else % select with random
            % A random BR is selected
            BRid(idV) = randi(appParams.Nbeacons,1,1);
        end
        
        
        
        
        
        
        
        

        % If it is not acceptable, it is reset to zero and a new random
        % value is obtained
        
        % Case coexistence with mitigation methods - limited by
        % superframe - i.e., if in ITS-G5 slot must be changed
        if simParams.technology==4 && simParams.coexMethod>0
            if ((simParams.coex_slotManagement == 1) ...
                    && mod(BRid(idV)-1,simParams.coex_superframeSF*appParams.NbeaconsF)+1 > (sinrManagement.coex_NtsLTE(1)*appParams.NbeaconsF)) || ...
                ((simParams.coex_slotManagement == 2) ...
                    && mod(BRid(idV)-1,simParams.coex_superframeSF*appParams.NbeaconsF)+1 > (ceil(simParams.coex_superframeSF/2)*appParams.NbeaconsF))
                BRid(idV) = 0;
            end
        end        
        
        % If it is outside the interval given by T1 and T2 it is not acceptable
        if T1>1 || T2<appParams.NbeaconsT
            subframeLastPacket = mod(ceil(timeManagement.timeLastPacket(IDvehicle(idV))/phyParams.TTI)-1,(appParams.NbeaconsT))+1;
            Tselected = ceil(BRid(idV)/appParams.NbeaconsF); 
            % IF Both T1 and T2 are within this beacon period
            if (subframeLastPacket+T2+1)<=appParams.NbeaconsT
                if Tselected<subframeLastPacket+T1 || Tselected>subframeLastPacket+T2
                   BRid(idV) = 0;
                end
            % IF Both are beyond this beacon period
            elseif (subframeLastPacket+T1-1)>appParams.NbeaconsT
                if Tselected<subframeLastPacket+T1-appParams.NbeaconsT || Tselected>subframeLastPacket+T2-appParams.NbeaconsT
                   BRid(idV) = 0;
                end
            % IF T1 within, T2 beyond
            else
                if Tselected<subframeLastPacket+T1 && Tselected>subframeLastPacket+T2-appParams.NbeaconsT
                   BRid(idV) = 0;
                end
            end 
        end
    end
end

Nreassign = Nvehicles;

end