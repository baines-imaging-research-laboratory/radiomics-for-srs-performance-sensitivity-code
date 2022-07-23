function bFinalBool = DoesChordIntersectWithPolygon(m2dPolygonCoords, vdLineCoords1, vdLineCoords2)

bFinalBool = false;

dNumPoints = size(m2dPolygonCoords,1)-1; % m2dPolygonCoords has same first and last point

% calc line segment slope, intersept, etc once
dChordCoords1_X = vdLineCoords1(1);
dChordCoords1_Y = vdLineCoords1(2);

dChordCoords2_X = vdLineCoords2(1);
dChordCoords2_Y = vdLineCoords2(2);

dMChord = (dChordCoords2_Y - dChordCoords1_Y) / (dChordCoords2_X - dChordCoords1_X); % where "(1)" are the x values, and "(2)" are the y values

bIsChordVertical = (dMChord == Inf || dMChord == -Inf);
bIsChordHorizontal = (dMChord == 0);

dNumIntersections = 0;

if bIsChordVertical
    dChordX = dChordCoords1_X; %
    
    bLastPointToLeft = m2dPolygonCoords(1,1) < dChordX;
    
    for dPointIndex=1:dNumPoints
        vdPoint = m2dPolygonCoords(dPointIndex,:);
        
        if vdPoint(1) < dChordX % left of line
            if ~bLastPointToLeft % we crossed the line
                bBool = CheckForTrueIntersection(...
                    vdLineCoords1, vdLineCoords2,...
                    vdPoint, m2dPolygonCoords(dPointIndex-1,:));
                
                if bBool
                    dNumIntersections = dNumIntersections + 1;
                    
                    if dNumIntersections > 2
                        bFinalBool = true;
                        break;
                    end
                end
                
                bLastPointToLeft = true;
            end
        elseif vdPoint(1) > dChordX % right of line
            if bLastPointToLeft % we crossed the line
                bBool = CheckForTrueIntersection(...
                    vdLineCoords1, vdLineCoords2,...
                    vdPoint, m2dPolygonCoords(dPointIndex-1,:));
                
                if bBool
                    dNumIntersections = dNumIntersections + 1;
                    
                    if dNumIntersections > 2
                        bFinalBool = true;
                        break;
                    end
                end
                
                bLastPointToLeft = false;
            end
        else % we're on the line
            bBool = CheckForTrueOnLine(...
                vdLineCoords1, vdLineCoords2,...
                vdPoint);
            
            if bBool
                dNumIntersections = dNumIntersections + 1;
                
                if dNumIntersections > 2
                    bFinalBool = true;
                    break;
                end
            end
            
            bLastPointToLeft = m2dPolygonCoords(dPointIndex+1,1) < dChordX;
        end
    end
elseif bIsChordHorizontal % chord is horizontal
    dChordY = dChordCoords1_Y; %
    
    bLastPointBelow = m2dPolygonCoords(1,2) < dChordY;
    
    for dPointIndex=1:dNumPoints
        vdPoint = m2dPolygonCoords(dPointIndex,:);
        
        if vdPoint(2) < dChordY % below line
            if ~bLastPointBelow % we crossed the line
                bBool = CheckForTrueIntersection(...
                    vdLineCoords1, vdLineCoords2,...
                    vdPoint, m2dPolygonCoords(dPointIndex-1,:));
                
                if bBool
                    dNumIntersections = dNumIntersections + 1;
                    
                    if dNumIntersections > 2
                        bFinalBool = true;
                        break;
                    end
                end
                
                bLastPointBelow = true;
            end
        elseif vdPoint(2) > dChordY % above line
            if bLastPointBelow % we crossed the line
                bBool = CheckForTrueIntersection(...
                    vdLineCoords1, vdLineCoords2,...
                    vdPoint, m2dPolygonCoords(dPointIndex-1,:));
                
                if bBool
                    dNumIntersections = dNumIntersections + 1;
                    
                    if dNumIntersections > 2
                        bFinalBool = true;
                        break;
                    end
                end
                
                bLastPointBelow = false;
            end
        else % we're on the line
            bBool = CheckForTrueOnLine(...
                vdLineCoords1, vdLineCoords2,...
                vdPoint);
            
            if bBool
                dNumIntersections = dNumIntersections + 1;
                
                if dNumIntersections > 2
                    bFinalBool = true;
                    break;
                end
            end
            
            bLastPointBelow = m2dPolygonCoords(dPointIndex+1,2) < dChordY;
        end
    end
else % chord is diagonal
    dDiffX = dChordCoords2_X - dChordCoords1_X;
    dDiffY = dChordCoords2_Y - dChordCoords1_Y;
    
    bLastPointToLeftAndAbove = ...
        ((m2dPolygonCoords(1,1)-dChordCoords1_X)*dDiffY - (m2dPolygonCoords(1,2)-dChordCoords1_Y)*dDiffX) < 0;
    
    for dPointIndex=1:dNumPoints
        vdPoint = m2dPolygonCoords(dPointIndex,:);
        
        dCurrentPointToLeftAndAboveValue = ...
            ((vdPoint(1)-dChordCoords1_X)*dDiffY - (vdPoint(2)-dChordCoords1_Y)*dDiffX);
        
        if dCurrentPointToLeftAndAboveValue < 0 % above/left
            if ~bLastPointToLeftAndAbove % we crossed the line
                bBool = CheckForTrueIntersection(...
                    vdLineCoords1, vdLineCoords2,...
                    vdPoint, m2dPolygonCoords(dPointIndex-1,:));
                
                if bBool
                    dNumIntersections = dNumIntersections + 1;
                    
                    if dNumIntersections > 2
                        bFinalBool = true;
                        break;
                    end
                end
                
                bLastPointToLeftAndAbove = true;
            end
        elseif dCurrentPointToLeftAndAboveValue > 0 % below/right
            if bLastPointToLeftAndAbove % we crossed the line
                bBool = CheckForTrueIntersection(...
                    vdLineCoords1, vdLineCoords2,...
                    vdPoint, m2dPolygonCoords(dPointIndex-1,:));
                
                if bBool
                    dNumIntersections = dNumIntersections + 1;
                    
                    if dNumIntersections > 2
                        bFinalBool = true;
                        break;
                    end
                end
                
                bLastPointToLeftAndAbove = false;
            end
        else % chord goes through the point (this should happen twice from the points the chord starts from)
            bBool = CheckForTrueOnLine(...
                vdLineCoords1, vdLineCoords2,...
                vdPoint);
            
            if bBool
                dNumIntersections = dNumIntersections + 1;
                
                if dNumIntersections > 2
                    bFinalBool = true;
                    break;
                end
            end
            
            bLastPointToLeftAndAbove = ...
                ((m2dPolygonCoords(dPointIndex+1,1)-dChordCoords1_X)*dDiffY - (m2dPolygonCoords(dPointIndex+1,2)-dChordCoords1_Y)*dDiffX) < 0;
        end
    end
    
end

end


function bBool = CheckForTrueIntersection(vdChordCoords1, vdChordCoords2, vdPoint1, vdPoint2)

bBool = false;

dErr = 1E-10;

% calc line segment slope, intersept, etc once
dChordCoords1_X = vdChordCoords1(1);
dChordCoords1_Y = vdChordCoords1(2);

dChordCoords2_X = vdChordCoords2(1);
dChordCoords2_Y = vdChordCoords2(2);

dChordMinX = min(dChordCoords1_X, dChordCoords2_X) - dErr;
dChordMaxX = max(dChordCoords1_X, dChordCoords2_X) + dErr;

dChordMinY = min(dChordCoords1_Y, dChordCoords2_Y) - dErr;
dChordMaxY = max(dChordCoords1_Y, dChordCoords2_Y) + dErr;

dMChord = (dChordCoords2_Y - dChordCoords1_Y) / (dChordCoords2_X - dChordCoords1_X); % where "(1)" are the x values, and "(2)" are the y values
dBChord = dChordCoords1_Y - (dMChord * dChordCoords1_X);

bIsChordVertical = (dMChord == Inf || dMChord == -Inf);

if bIsChordVertical
    dPolyLineCoords1_X = vdPoint1(1);
    dPolyLineCoords1_Y = vdPoint1(2);
    
    dPolyLineCoords2_X = vdPoint2(1);
    dPolyLineCoords2_Y = vdPoint2(2);
    
    dMPolyLine = (dPolyLineCoords2_Y - dPolyLineCoords1_Y) / (dPolyLineCoords2_X - dPolyLineCoords1_X);
    
    if isfinite(dMPolyLine) && (dMChord ~= dMPolyLine)
        dBPolyLine = dPolyLineCoords1_Y - (dMPolyLine * dPolyLineCoords1_X);
        
        dPolyLineMinX = min(dPolyLineCoords1_X, dPolyLineCoords2_X);
        dPolyLineMaxX = max(dPolyLineCoords1_X, dPolyLineCoords2_X);
        
        dIntersectionX = (dBPolyLine - dBChord) / (dMChord - dMPolyLine);
        
        if ...
                dIntersectionX + dErr >= dPolyLineMinX &&....
                dIntersectionX - dErr <= dPolyLineMaxX &&...
                dIntersectionX >= dChordMinX &&....
                dIntersectionX <= dChordMaxX
            
            bBool = true;
        end
    else % both are vertical; check that x's are equal, y's are bounded
        if ...
                dPolyLineCoords1_X >= dChordMinX &&...
                dPolyLineCoords1_X <= dChordMaxX &&...
                dPolyLineCoords1_Y >= dChordMinY &&...
                dPolyLineCoords2_Y <= dChordMaxY
            
            bBool = true;
        end
    end
else % chord is not vertical
    dPolyLineCoords1_X = vdPoint1(1);
    dPolyLineCoords1_Y = vdPoint1(2);
    
    dPolyLineCoords2_X = vdPoint2(1);
    dPolyLineCoords2_Y = vdPoint2(2);
    
    dMPolyLine = (dPolyLineCoords2_Y - dPolyLineCoords1_Y) / (dPolyLineCoords2_X - dPolyLineCoords1_X);
    
    if isfinite(dMPolyLine) && (dMChord ~= dMPolyLine)
        dBPolyLine = dPolyLineCoords1_Y - (dMPolyLine * dPolyLineCoords1_X);
        
        dPolyLineMinX = min(dPolyLineCoords1_X, dPolyLineCoords2_X);
        dPolyLineMaxX = max(dPolyLineCoords1_X, dPolyLineCoords2_X);
        
        dIntersectionX = (dBPolyLine - dBChord) / (dMChord - dMPolyLine);
        
        if ...
                dIntersectionX + dErr >= dPolyLineMinX &&....
                dIntersectionX - dErr <= dPolyLineMaxX &&...
                dIntersectionX >= dChordMinX &&....
                dIntersectionX <= dChordMaxX
            
            bBool = true;
        end
    elseif ~isfinite(dMPolyLine) % poly line is vertical
        dIntersectionY = dMChord * dPolyLineCoords1_X + dBChord; % dPolyLineCoords1_X == dPolyLineCoords2_X if line is vertical
        
        dPolyLineMinY = min(dPolyLineCoords1_Y, dPolyLineCoords2_Y);
        dPolyLineMaxY = max(dPolyLineCoords1_Y, dPolyLineCoords2_Y);
        
        if ...
                dIntersectionY + dErr >= dPolyLineMinY &&....
                dIntersectionY - dErr <= dPolyLineMaxY &&...
                dIntersectionY + dErr >= dChordMinY &&....
                dIntersectionY - dErr <= dChordMaxY
            
            bBool = true;
        end
    elseif dMChord == dMPolyLine
        dPolyLineMinX = min(dPolyLineCoords1_X, dPolyLineCoords2_X);
        dPolyLineMaxX = max(dPolyLineCoords1_X, dPolyLineCoords2_X);
        
        if...
                dPolyLineMinX >= dChordMinX &&...
                dPolyLineMaxX <= dChordMaxX
            
            bBool = true;
        end
        
    end % if is parallel (e.g. dMChord == dMPolyLine), not need to check, it will detect intersection with the start/end points of that line segment if they do intersect
    
end
end


function bBool = CheckForTrueOnLine(vdChordCoords1, vdChordCoords2, vdPoint)
   
dChordCoords1_X = vdChordCoords1(1);
dChordCoords1_Y = vdChordCoords1(2);

dChordCoords2_X = vdChordCoords2(1);
dChordCoords2_Y = vdChordCoords2(2);

dChordMinX = min(dChordCoords1_X, dChordCoords2_X);
dChordMaxX = max(dChordCoords1_X, dChordCoords2_X);

dChordMinY = min(dChordCoords1_Y, dChordCoords2_Y);
dChordMaxY = max(dChordCoords1_Y, dChordCoords2_Y);

bBool = ...
    vdPoint(1) >= dChordMinX &&...
    vdPoint(1) <= dChordMaxX &&...
    vdPoint(2) >= dChordMinY &&...
    vdPoint(2) <= dChordMaxY;

end