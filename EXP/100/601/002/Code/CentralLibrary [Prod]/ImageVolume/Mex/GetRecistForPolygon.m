function [dRecist, vdRecistPoint1, vdRecistPoint2] = GetRecistForPolygon(m2dPolygonCoords)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

m2dPolygonCoords = [m2dPolygonCoords; m2dPolygonCoords(1,:)];

% figure();plot(m2dPolygonCoords(:,1),m2dPolygonCoords(:,2),'*-','Color','b');
% hold on;
% grid on;
% axis equal;

m2dPolygonCoords = RemoveCollinearPoints(m2dPolygonCoords);

dNumPoints = size(m2dPolygonCoords,1)-1;

dRecistSquared = 0;
vdRecistPoint1 = [];
vdRecistPoint2 = [];


for dStartPointIndex=1:dNumPoints
    vdStartPoint = m2dPolygonCoords(dStartPointIndex,:);
    
%     hStartPoint = plot(vdStartPoint(1), vdStartPoint(2), '.', 'MarkerSize', 20, 'MarkerEdgeColor', 'r');
    
    for dSearchPointIndex = dStartPointIndex+1:dNumPoints
        vdSearchPoint = m2dPolygonCoords(dSearchPointIndex,:);
        
%         hSearchPoint = plot(vdSearchPoint(1), vdSearchPoint(2), '.', 'MarkerSize', 20, 'MarkerEdgeColor', 'g');
        
        [dNewRecistSquared, vdNewRecistPoint1, vdNewRecistPoint2] = GetLongestDistanceSquaredWithinPolygon(vdStartPoint, vdSearchPoint, m2dPolygonCoords);
        
        if dNewRecistSquared > dRecistSquared
            dRecistSquared = dNewRecistSquared;
            vdRecistPoint1 = vdNewRecistPoint1;
            vdRecistPoint2 = vdNewRecistPoint2;
        end
        
%         if dNewRecistSquared ~= 0
%             hRecist = plot([vdNewRecistPoint1(1) vdNewRecistPoint2(1)],[vdNewRecistPoint1(2) vdNewRecistPoint2(2)],'Color','k','LineWidth',2);
%         else
%             hRecist = plot([vdStartPoint(1) vdSearchPoint(1)],[vdStartPoint(2) vdSearchPoint(2)],'Color','r','LineWidth',2,'LineStyle','--');
%         end
                
%         delete(hSearchPoint);
%         delete(hRecist);
    end
    
%     delete(hStartPoint);
end


% hRecist = plot([vdRecistPoint1(1) vdRecistPoint2(1)],[vdRecistPoint1(2) vdRecistPoint2(2)],'Color','k','LineWidth',2);

dRecist = sqrt(dRecistSquared);

% disp(dRecist);

end

function m2dPolygonCoords = RemoveCollinearPoints(m2dPolygonCoords)
dEps = 0.001;
dNumPoints = size(m2dPolygonCoords,1);

vbKeepPoint = true(dNumPoints,1);
vbKeepPoint(end) = false;

bPrevLineWasVertical = abs(m2dPolygonCoords(end,1) - m2dPolygonCoords(end-1,1)) <= dEps;

[dPrevLineMEpsXMin, dPrevLineMEpsXMax, dPrevLineMEpsYMin, dPrevLineMEpsYMax] = GetLineMWithEpsShifts(m2dPolygonCoords(end-1,:), m2dPolygonCoords(end,:), dEps);

dRowIndex = 1;

vdNextPoint = m2dPolygonCoords(1,:);

dPoint1Index = 1;

while dRowIndex <= dNumPoints-1
    vdCurrentPoint = vdNextPoint;
    vdNextPoint = m2dPolygonCoords(dRowIndex+1,:);
    
    if all(abs(vdCurrentPoint - vdNextPoint) <= dEps) % same point, just remove it, stay at current point
        vbKeepPoint(dRowIndex+1) = false;
        vdNextPoint = vdCurrentPoint;
    else
        bNextLineIsVertical = abs(vdCurrentPoint(1) - vdNextPoint(1)) <= dEps;
        
        if ~xor(bPrevLineWasVertical, bNextLineIsVertical)
            if bPrevLineWasVertical && bNextLineIsVertical % collinear!
                vbKeepPoint(dPoint1Index) = false;
            else % both weren't vertical, need to compare slopes
                dNextLineM = (vdNextPoint(2) - vdCurrentPoint(2)) / (vdNextPoint(1) - vdCurrentPoint(1));
                
                if ...% equal within tolerance: collinear!
                        dNextLineM >= dPrevLineMEpsXMin && ...
                        dNextLineM <= dPrevLineMEpsXMax && ...
                        dNextLineM >= dPrevLineMEpsYMin && ...
                        dNextLineM <= dPrevLineMEpsYMax
                    vbKeepPoint(dPoint1Index) = false;
                else % not collinear
                    bPrevLineWasVertical = false;
                    
                    [dPrevLineMEpsXMin, dPrevLineMEpsXMax, dPrevLineMEpsYMin, dPrevLineMEpsYMax] = GetLineMWithEpsShifts(vdCurrentPoint, vdNextPoint, dEps);
                end
            end
        else % one and only one of the lines was vertical: not collinear
            bPrevLineWasVertical = bNextLineIsVertical;
            
            if ~bNextLineIsVertical
                [dPrevLineMEpsXMin, dPrevLineMEpsXMax, dPrevLineMEpsYMin, dPrevLineMEpsYMax] = GetLineMWithEpsShifts(vdCurrentPoint, vdNextPoint, dEps);
            end
        end
        
        dPoint1Index = dRowIndex + 1;
    end
    
    dRowIndex = dRowIndex + 1;
end

m2dPolygonCoords = m2dPolygonCoords(vbKeepPoint,:);

m2dPolygonCoords = [m2dPolygonCoords; m2dPolygonCoords(1,:)];
end

function [dEpsXMin, dEpsXMax, dEpsYMin, dEpsYMax] = GetLineMWithEpsShifts(vdPoint1, vdPoint2, dEps)

dCurrentLineM_EpsX1 = (vdPoint2(2) - vdPoint1(2)) / (vdPoint2(1) - vdPoint1(1) - dEps);
dCurrentLineM_EpsX2 = (vdPoint2(2) - vdPoint1(2)) / (vdPoint2(1) - vdPoint1(1) + dEps);

dCurrentLineM_EpsY1 = (vdPoint2(2) - vdPoint1(2) - dEps) / (vdPoint2(1) - vdPoint1(1));
dCurrentLineM_EpsY2 = (vdPoint2(2) - vdPoint1(2) + dEps) / (vdPoint2(1) - vdPoint1(1));

dEpsXMin = min(dCurrentLineM_EpsX1, dCurrentLineM_EpsX2);
dEpsXMax = max(dCurrentLineM_EpsX1, dCurrentLineM_EpsX2);

dEpsYMin = min(dCurrentLineM_EpsY1, dCurrentLineM_EpsY2);
dEpsYMax = max(dCurrentLineM_EpsY1, dCurrentLineM_EpsY2);
end

function [dFinalLengthSquared, vdFinalRecistPoint1, vdFinalRecistPoint2] = GetLongestDistanceSquaredWithinPolygon(vdChordPoint1, vdChordPoint2, m2dPolygonCoords)
dFinalLengthSquared = 0;

vdFinalRecistPoint1 = [];
vdFinalRecistPoint2 = [];

bChordIsVertical = vdChordPoint1(1) == vdChordPoint2(1);

if vdChordPoint1(1) < vdChordPoint2(1)
    vdLeftChordPoint = vdChordPoint1;
    vdRightChordPoint = vdChordPoint2;
else
    vdLeftChordPoint = vdChordPoint2;
    vdRightChordPoint = vdChordPoint1;
end

dChordM = (vdRightChordPoint(2) - vdLeftChordPoint(2)) / (vdRightChordPoint(1) - vdLeftChordPoint(1));
dChordB = vdLeftChordPoint(2) - dChordM * vdLeftChordPoint(1);


dErr = 0.001;

% if bChordIsVertical
%     
%     bSomePartOfChordIsInPolygon = inpolygon_optimized(vdChordPoint1(1)+dErr,mean([vdChordPoint1(2),vdChordPoint2(2)]),m2dPolygonCoords(:,1),m2dPolygonCoords(:,2));
% else
%     
%       
%     vdMidChordPoint = (vdLeftChordPoint + vdRightChordPoint) ./ 2;
%     
%     
%     if dChordM == 0
%         vdMidChordPointTest1 = vdMidChordPoint + [0 dErr];
%         vdMidChordPointTest2 = vdMidChordPoint + [0 -dErr];
%     else
%         vdMidChordPointTest1 = vdMidChordPoint + [dErr dErr*(-1/dChordM)];
%         vdMidChordPointTest2 = vdMidChordPoint - [dErr dErr*(-1/dChordM)];
%     end
%     
%     bSomePartOfChordIsInPolygon = ...
%         inpolygon_optimized(vdMidChordPointTest1(1), vdMidChordPointTest1(2), m2dPolygonCoords(:,1),m2dPolygonCoords(:,2)) ||...
%         inpolygon_optimized(vdMidChordPointTest2(1), vdMidChordPointTest2(2), m2dPolygonCoords(:,1),m2dPolygonCoords(:,2));
% end


    dNumPoints = size(m2dPolygonCoords,1) - 1;
    
    % CHORD IS VERTICAL
    if bChordIsVertical
        dChordX = vdChordPoint1(1);
        
        dChordMinY = min(vdChordPoint1(2), vdChordPoint2(2));
        dChordMaxY = max(vdChordPoint1(2), vdChordPoint2(2));
        
        vdLinePoint2 = m2dPolygonCoords(1,:);
        
        bChordValid = true;
        
        dMinAboveChordIntersectionY = Inf;
        dMaxBelowChordIntersectionY = -Inf;
        
        dNumIntersectionsAboveChord = 0;
        dNumIntersectionsBelowChord = 0;
        
        % check for intersections with polygon edges
        for dPointIndex=1:dNumPoints
            vdLinePoint1 = vdLinePoint2;
            vdLinePoint2 = m2dPolygonCoords(dPointIndex+1,:);
            
            if ... % no need to check for intersection for the line segments connected directly to the points the chord is from
                    ~all(vdLinePoint1 == vdChordPoint1) && ...
                    ~all(vdLinePoint1 == vdChordPoint2) && ...
                    ~all(vdLinePoint2 == vdChordPoint1) && ...
                    ~all(vdLinePoint2 == vdChordPoint2)
                
                dMinX = min(vdLinePoint1(1),vdLinePoint2(1));
                dMaxX = max(vdLinePoint1(1),vdLinePoint2(1));
                
                if dChordX > dMinX && dChordX < dMaxX % intersection occurred
                    if vdLinePoint1(1) ~= vdLinePoint2(1)
                        dLineM = (vdLinePoint2(2) - vdLinePoint1(2)) / (vdLinePoint2(1) - vdLinePoint1(1));
                        dLineB = vdLinePoint1(2) - dLineM * vdLinePoint1(1);
                        
                        dIntersectionY = dLineM * dChordX + dLineB;
                        
                        if dIntersectionY > dChordMinY && dIntersectionY < dChordMaxY % chord intersected with edge
                            bChordValid = false;
                            break;
                        elseif dIntersectionY < dChordMinY % below chord intersection
                            dMaxBelowChordIntersectionY = max(dMaxBelowChordIntersectionY, dIntersectionY);
                            dNumIntersectionsBelowChord = dNumIntersectionsBelowChord + 1;
                        else % dIntersection > dChordMax % above chord intersection
                            dMinAboveChordIntersectionY = min(dMinAboveChordIntersectionY, dIntersectionY);
                            dNumIntersectionsAboveChord = dNumIntersectionsAboveChord + 1;
                        end
                    end
                end
            end
        end
            
        % check all intersections with vertices (EXACTLY)
        
        for dPointIndex=1:dNumPoints
            vdVertex = m2dPolygonCoords(dPointIndex,:);
            
            if VertexIsNotChordPoint(vdVertex, vdChordPoint1, vdChordPoint2)
                
                if vdVertex(1) == dChordX
                    
                    if ~VertexIsHorizontalSpike(m2dPolygonCoords, dPointIndex, dChordX)
                        dVertexY = vdVertex(2);
                        
                        if dChordMinY < dVertexY && dVertexY < dChordMaxY
                            bChordValid = false;
                            break;
                        elseif dVertexY < dChordMinY % intersection on below chord
                            dMaxBelowChordIntersectionY = max(dMaxBelowChordIntersectionY, dVertexY);
                            dNumIntersectionsBelowChord = dNumIntersectionsBelowChord + 1;
                        else
                            dMinAboveChordIntersectionY = min(dMinAboveChordIntersectionY, dVertexY);
                            dNumIntersectionsAboveChord = dNumIntersectionsAboveChord + 1;
                        end
                    end
                end
            end
        end
        
        % finished checking all intersections
        if dNumIntersectionsAboveChord + dNumIntersectionsBelowChord == 0
            % it's either in the polygon and nothing got in the way
            % (e.g concave polygon) or it could pass entirely on the
            % outside of the polygon (e.g. crescent moon)
            
            vdMidPoint = [dChordX, (vdChordPoint1(2) + vdChordPoint2(2)) / 2];
            
            if ... % use some little nudges incase its lying along an edge
                    ~inpolygon_optimized(vdMidPoint(1) + dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                    ~inpolygon_optimized(vdMidPoint(1) - dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                bChordValid = false;
            end
        end
        
        if bChordValid
            bNumIntersectionsAboveChordIsOdd = mod(dNumIntersectionsAboveChord,2) == 1;
            bNumIntersectionsBelowChordIsOdd = mod(dNumIntersectionsBelowChord,2) == 1;
            
            bCheckBelowBottomChordPoint = false;
            
            if ~bNumIntersectionsAboveChordIsOdd || dMinAboveChordIntersectionY == Inf % no intersection or no intersection that stayed within polygon
                vdRecistPoint1 = [dChordX, dChordMaxY];
            else % extension of chord upwards
                vdRecistPoint1 = [dChordX, dMinAboveChordIntersectionY];
                bCheckBelowBottomChordPoint = true;
            end
            
            bCheckAboveTopChordPoint = false;
            
            if ~bNumIntersectionsBelowChordIsOdd || dMaxBelowChordIntersectionY == -Inf % no intersection or no intersection that stayed within polygon
                vdRecistPoint2 = [dChordX, dChordMinY];
            else % extension of chord upwards
                vdRecistPoint2 = [dChordX, dMaxBelowChordIntersectionY];
                bCheckAboveTopChordPoint = true;
            end
            
            % check that all line segments are within polygon
            bAllMidPointsWithinPolygon = true;
            
            % check between original chord points
            vdMidPoint = [dChordX, (vdChordPoint1(2) + vdChordPoint2(2)) / 2];
            
            if ... % use some little nudges incase its lying along an edge
                    ~inpolygon_optimized(vdMidPoint(1) + dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                    ~inpolygon_optimized(vdMidPoint(1) - dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                bAllMidPointsWithinPolygon = false;
            end
            
            if bAllMidPointsWithinPolygon && bCheckBelowBottomChordPoint
                vdMidPoint = [dChordX, (dChordMaxY + vdRecistPoint1(2)) / 2];
                
                if ... % use some little nudges incase its lying along an edge
                        ~inpolygon_optimized(vdMidPoint(1) + dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                        ~inpolygon_optimized(vdMidPoint(1) - dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                    bAllMidPointsWithinPolygon = false;
                end
            end
            
            if bAllMidPointsWithinPolygon && bCheckAboveTopChordPoint
                vdMidPoint = [dChordX, (dChordMinY + vdRecistPoint2(2)) / 2];
                
                if ... % use some little nudges incase its lying along an edge
                        ~inpolygon_optimized(vdMidPoint(1) + dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                        ~inpolygon_optimized(vdMidPoint(1) - dErr, vdMidPoint(2), m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                    bAllMidPointsWithinPolygon = false;
                end
            end
            
            % finally: if everything checks out, see if line segment is
            % longer
            if bAllMidPointsWithinPolygon
                dNewLengthSquared = (vdRecistPoint2(2) - vdRecistPoint1(2))^2;
                
                if dNewLengthSquared > dFinalLengthSquared
                    dFinalLengthSquared = dNewLengthSquared;
                    
                    vdFinalRecistPoint1 = vdRecistPoint1;
                    vdFinalRecistPoint2 = vdRecistPoint2;
                end
            end
        end
        
        
        
    % CHORD HAS SLOPE
    else 
        
        dMinChordX = min(vdLeftChordPoint(1), vdRightChordPoint(1));
        dMaxChordX = max(vdLeftChordPoint(1), vdRightChordPoint(1));
        
        vdLinePoint2 = m2dPolygonCoords(1,:);
        
        bChordValid = true;
        
        dMinRightOfChordIntersectionX = Inf;
        dMaxLeftOfChordIntersectionX = -Inf;
        
        dNumIntersectionsLeftOfChord = 0;
        dNumIntersectionsRightOfChord = 0;
        
        % check all intersections with line segments (NOT VERTICES)
        for dPointIndex=1:dNumPoints
            vdLinePoint1 = vdLinePoint2;
            vdLinePoint2 = m2dPolygonCoords(dPointIndex+1,:);
            
            if LineDoesNotShareVertexWithChord(vdLinePoint1, vdLinePoint2, vdLeftChordPoint, vdRightChordPoint)  ... % no need to check for intersection for the line segments connected directly to the points the chord is from
                    
                bIntersectionOccurred = false;
                dIntersectionX = 0; % only for pre-allocation in mex, 0 never used
                
                if vdLinePoint1(1) == vdLinePoint2(1) % line is vertical
                    dIntersectionY = dChordM * vdLinePoint1(1) + dChordB;
                    
                    if ...
                            dIntersectionY > min(vdLinePoint1(2), vdLinePoint2(2)) &&...
                            dIntersectionY < max(vdLinePoint1(2), vdLinePoint2(2))
                        bIntersectionOccurred = true;
                        dIntersectionX = vdLinePoint1(1);
                    end
                else % both lines are sloped
                    dLineM = (vdLinePoint2(2) - vdLinePoint1(2)) / (vdLinePoint2(1) - vdLinePoint1(1));
                    dLineB = vdLinePoint1(2) - dLineM * vdLinePoint1(1);
                    
                    dIntersectionX = (dLineB - dChordB) / (dChordM - dLineM);
                    
                    if ...
                            dIntersectionX > min(vdLinePoint1(1), vdLinePoint2(1)) &&...
                            dIntersectionX < max(vdLinePoint1(1), vdLinePoint2(1))
                        bIntersectionOccurred = true;
                    end
                end
                
                if bIntersectionOccurred
                    if dIntersectionX > dMinChordX && dIntersectionX < dMaxChordX % chord intersected
                        bChordValid = false;
                        break;
                    elseif dIntersectionX < vdLeftChordPoint(1)
                        dMaxLeftOfChordIntersectionX = max(dMaxLeftOfChordIntersectionX, dIntersectionX);
                        dNumIntersectionsLeftOfChord = dNumIntersectionsLeftOfChord + 1;
                    else
                        dMinRightOfChordIntersectionX = min(dMinRightOfChordIntersectionX, dIntersectionX);
                        dNumIntersectionsRightOfChord = dNumIntersectionsRightOfChord + 1;
                    end
                end
            end
        end
        
        % check all intersections with vertices (EXACTLY)
        
        for dPointIndex=1:dNumPoints
            vdVertex = m2dPolygonCoords(dPointIndex,:);
            
            if VertexIsNotChordPoint(vdVertex, vdLeftChordPoint, vdRightChordPoint)
                    
                if VertexIsOnChord(vdVertex, vdLeftChordPoint, vdRightChordPoint)
                    
                    if ~VertexIsSpike(m2dPolygonCoords, dPointIndex, vdLeftChordPoint, vdRightChordPoint)
                        dVertexX = vdVertex(1);
                        
                        if vdLeftChordPoint(1) < dVertexX && dVertexX < vdRightChordPoint(1)
                            bChordValid = false;
                            break;
                        elseif dVertexX < vdLeftChordPoint(1) % intersection on left side of chord
                            dMaxLeftOfChordIntersectionX = max(dMaxLeftOfChordIntersectionX, dVertexX);
                            dNumIntersectionsLeftOfChord = dNumIntersectionsLeftOfChord + 1;
                        else
                            dMinRightOfChordIntersectionX = min(dMinRightOfChordIntersectionX, dVertexX);
                            dNumIntersectionsRightOfChord = dNumIntersectionsRightOfChord + 1;
                        end
                    end
                end
            end
        end        
        
        % finished checking all intersections
        if dNumIntersectionsLeftOfChord + dNumIntersectionsRightOfChord == 0
            
        end
        
        if bChordValid            
            bNumIntersectionsLeftOfChordIsOdd = mod(dNumIntersectionsLeftOfChord,2) == 1;
            bNumIntersectionsRightOfChordIsOdd = mod(dNumIntersectionsRightOfChord,2) == 1;
            
            bCheckToLeftMidpoint = false;
            
            if ~bNumIntersectionsLeftOfChordIsOdd || dMaxLeftOfChordIntersectionX == -Inf % no intersection or no intersection that stayed within polygon
                vdRecistPoint1 = vdLeftChordPoint;
            else % extension of chord leftwards
                vdRecistPoint1 = [dMaxLeftOfChordIntersectionX, dChordM*dMaxLeftOfChordIntersectionX+dChordB];
                bCheckToLeftMidpoint = true;
            end
            
            bCheckToRightMidpoint = false;
            
            if ~bNumIntersectionsRightOfChordIsOdd  || dMinRightOfChordIntersectionX == Inf % no intersection or no intersection that stayed within polygon
                vdRecistPoint2 = vdRightChordPoint;
            else % extension of chord upwards
                vdRecistPoint2 = [dMinRightOfChordIntersectionX, dChordM*dMinRightOfChordIntersectionX+dChordB];
                bCheckToRightMidpoint = true;
            end
            
            % check that all line segments are within the polygon
            bAllMidPointsWithinPolygon = true;
            
            % it's either in the polygon and nothing got in the way
            % (e.g concave polygon) or it could pass entirely on the
            % outside of the polygon (e.g. crescent moon)
            
            vdMidPoint = (vdLeftChordPoint + vdRightChordPoint) / 2;
            
            if ... % use some little nudges incase its lying along an edge
                    ~inpolygon_optimized(vdMidPoint(1), vdMidPoint(2) + dErr, m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                    ~inpolygon_optimized(vdMidPoint(1), vdMidPoint(2) - dErr, m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                bAllMidPointsWithinPolygon = false;
            end
            
            if bAllMidPointsWithinPolygon && bCheckToLeftMidpoint
                vdMidPoint = (vdLeftChordPoint + vdRecistPoint1) / 2;
                
                if ... % use some little nudges incase its lying along an edge
                        ~inpolygon_optimized(vdMidPoint(1), vdMidPoint(2) + dErr, m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                        ~inpolygon_optimized(vdMidPoint(1), vdMidPoint(2) - dErr, m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                    bAllMidPointsWithinPolygon = false;
                end
            end
            
            if bAllMidPointsWithinPolygon && bCheckToRightMidpoint
                vdMidPoint = (vdRightChordPoint + vdRecistPoint2) / 2;
                
                if ... % use some little nudges incase its lying along an edge
                        ~inpolygon_optimized(vdMidPoint(1), vdMidPoint(2) + dErr, m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2)) && ...
                        ~inpolygon_optimized(vdMidPoint(1), vdMidPoint(2) - dErr, m2dPolygonCoords(1:end,1), m2dPolygonCoords(1:end,2))
                    bAllMidPointsWithinPolygon = false;
                end
            end
            
            
            % finally check if chord is longer
            if bAllMidPointsWithinPolygon
                dNewLengthSquared = sum((vdRecistPoint2 - vdRecistPoint1).^2);
                
                if dNewLengthSquared > dFinalLengthSquared
                    dFinalLengthSquared = dNewLengthSquared;
                    
                    vdFinalRecistPoint1 = vdRecistPoint1;
                    vdFinalRecistPoint2 = vdRecistPoint2;
                end
            end
        end
    end
end

function bBool = inpolygon_optimized(dMidPointX, dMidPointY, vdPolygonCoordsX, vdPolygonCoordsY)

dWindingNumber = 0;
    
for dPointIndex=1:length(vdPolygonCoordsX)-1
    if vdPolygonCoordsY(dPointIndex) <= dMidPointY
        if vdPolygonCoordsY(dPointIndex+1) > dMidPointY
            if GetLeftAndAboveValue(...
                    vdPolygonCoordsX(dPointIndex), vdPolygonCoordsY(dPointIndex),...
                    vdPolygonCoordsX(dPointIndex+1), vdPolygonCoordsY(dPointIndex+1),...
                    dMidPointX, dMidPointY) >= 0
                dWindingNumber = dWindingNumber + 1;
            end
        end
    else
        if vdPolygonCoordsY(dPointIndex+1) <= dMidPointY    
            if GetLeftAndAboveValue(...
                    vdPolygonCoordsX(dPointIndex), vdPolygonCoordsY(dPointIndex),...
                    vdPolygonCoordsX(dPointIndex+1), vdPolygonCoordsY(dPointIndex+1),...
                    dMidPointX, dMidPointY) <= 0
                dWindingNumber = dWindingNumber - 1;
            end
        end
    end
end
    
bBool = dWindingNumber ~= 0;

end

function dLeftVal = GetLeftAndAboveValue(dLinePoint1X, dLinePoint1Y, dLinePoint2X, dLinePoint2Y, dPointX, dPointY)

    dLeftVal = ...
        (dLinePoint2X - dLinePoint1X)*(dPointY-dLinePoint1Y) -...
        (dLinePoint2Y - dLinePoint1Y)*(dPointX-dLinePoint1X);
end

function bBool = LineDoesNotShareVertexWithChord(vdLinePoint1, vdLinePoint2, vdLeftChordPoint, vdRightChordPoint)
    bBool =...
    ~all(vdLinePoint1 == vdLeftChordPoint) && ...
    ~all(vdLinePoint1 == vdRightChordPoint) && ...
    ~all(vdLinePoint2 == vdLeftChordPoint) && ...
    ~all(vdLinePoint2 == vdRightChordPoint);
end

function bBool = VertexIsNotChordPoint(vdVertex, vdLeftChordPoint, vdRightChordPoint)
bBool = ...
    ~all(vdVertex == vdLeftChordPoint) && ...
    ~all(vdVertex == vdRightChordPoint);
end

function bBool = VertexIsOnChord(vdVertex, vdLeftChordPoint, vdRightChordPoint)
   bBool = 0 == GetLeftAndAboveValue(vdLeftChordPoint(1), vdLeftChordPoint(2), vdRightChordPoint(1), vdRightChordPoint(2), vdVertex(1), vdVertex(2));
end
   
function bBool = VertexIsSpike(m2dPolygonCoords, dVertexIndex, vdLeftChordPoint, vdRightChordPoint)
    dNumPoints = size(m2dPolygonCoords,1)-1;

    bDecreasingIndexLeftAndAbovePositive = false;
    bNonChordVertexFound = false;
    
    dSearchIndex = dVertexIndex - 1;
    
    while ~bNonChordVertexFound
        if dSearchIndex == 0
            dSearchIndex = dNumPoints;
        end
        
        vdVertex = m2dPolygonCoords(dSearchIndex,:);
        
        if ~VertexIsOnChord(vdVertex, vdLeftChordPoint, vdRightChordPoint)
            bNonChordVertexFound = true;
            bDecreasingIndexLeftAndAbovePositive = 0 < GetLeftAndAboveValue(vdLeftChordPoint(1), vdLeftChordPoint(2), vdRightChordPoint(1), vdRightChordPoint(2), vdVertex(1), vdVertex(2));
        end
        
        dSearchIndex = dSearchIndex - 1;
    end
    
    bIncreasingIndexLeftAndAbovePositive = false;    
    bNonChordVertexFound = false;
    
    dSearchIndex = dVertexIndex + 1;
    
    while ~bNonChordVertexFound
        if dSearchIndex > dNumPoints
            dSearchIndex = 1;
        end
        
        vdVertex = m2dPolygonCoords(dSearchIndex,:);
        
        if ~VertexIsOnChord(vdVertex, vdLeftChordPoint, vdRightChordPoint)
            bNonChordVertexFound = true;
            bIncreasingIndexLeftAndAbovePositive = 0 < GetLeftAndAboveValue(vdLeftChordPoint(1), vdLeftChordPoint(2), vdRightChordPoint(1), vdRightChordPoint(2), vdVertex(1), vdVertex(2));
        end
        
        dSearchIndex = dSearchIndex + 1;
    end
    
    bBool = bDecreasingIndexLeftAndAbovePositive == bIncreasingIndexLeftAndAbovePositive;
end

function bBool = VertexIsHorizontalSpike(m2dPolygonCoords, dVertexIndex, dChordX)
    dNumPoints = size(m2dPolygonCoords,1)-1;

    bDecreasingIndexToLeftOfChord = false;
    bNonChordVertexFound = false;
    
    dSearchIndex = dVertexIndex - 1;
    
    while ~bNonChordVertexFound
        if dSearchIndex == 0
            dSearchIndex = dNumPoints;
        end
        
        vdVertex = m2dPolygonCoords(dSearchIndex,:);
        
        if vdVertex(1) ~= dChordX
            bNonChordVertexFound = true;
            bDecreasingIndexToLeftOfChord = vdVertex(1) < dChordX;
        end
        
        dSearchIndex = dSearchIndex - 1;
    end
    
    bIncreasingIndexToLeftOfChord = false;    
    bNonChordVertexFound = false;
    
    dSearchIndex = dVertexIndex + 1;
    
    while ~bNonChordVertexFound
        if dSearchIndex > dNumPoints
            dSearchIndex = 1;
        end
        
        vdVertex = m2dPolygonCoords(dSearchIndex,:);
        
        if vdVertex(1) ~= dChordX
            bNonChordVertexFound = true;
            bIncreasingIndexToLeftOfChord = vdVertex(1) < dChordX;
        end
        
        dSearchIndex = dSearchIndex + 1;
    end
    
    bBool = bDecreasingIndexToLeftOfChord == bIncreasingIndexToLeftOfChord;
end