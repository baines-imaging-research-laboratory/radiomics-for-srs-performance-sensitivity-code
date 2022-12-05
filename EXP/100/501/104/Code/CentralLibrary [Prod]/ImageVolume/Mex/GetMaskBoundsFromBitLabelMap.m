function [vdRowBounds, vdColBounds, vdSliceBounds] = GetMaskBoundsFromBitLabelMap(m3iBitLabelMap, dBitPosition)

% find bounds

vdDims  = [size(m3iBitLabelMap,1), size(m3iBitLabelMap,2), size(m3iBitLabelMap,3)];
bTrueValueFound = false;

% - find min row

dMinRow = 1;

for dRow=1:vdDims(1)
    bTrueValueFound = false;
    
    for dSlice=1:vdDims(3)
        for dCol=1:vdDims(2)
            if 1 == bitget(m3iBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                bTrueValueFound = true;
                dMinRow = dRow;
                break
            end
        end
        
        if bTrueValueFound
            break;
        end
    end
    
    if bTrueValueFound
        break;
    end
end

if ~bTrueValueFound
    vdRowBounds = [];
    vdColBounds = [];
    vdSliceBounds = [];
else
    
    % - find max row
    
    dMaxRow = vdDims(1);
    
    for dRow=vdDims(1):-1:1
        bTrueValueFound = false;
        
        for dSlice=1:vdDims(3)
            for dCol=1:vdDims(2)
                if 1 == bitget(m3iBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                    bTrueValueFound = true;
                    dMaxRow = dRow;
                    break
                end
            end
            
            if bTrueValueFound
                break;
            end
        end
        
        if bTrueValueFound
            break;
        end
    end
    
    % - find min col
    
    dMinCol = 1;
    
    for dCol=1:vdDims(2)
        bTrueValueFound = false;
        
        for dSlice=1:vdDims(3)
            for dRow=1:vdDims(1)
                if 1 == bitget(m3iBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                    bTrueValueFound = true;
                    dMinCol = dCol;
                    break
                end
            end
            
            if bTrueValueFound
                break;
            end
        end
        
        if bTrueValueFound
            break;
        end
    end
    
    % - find max col
    
    dMaxCol = vdDims(2);
    
    for dCol=vdDims(2):-1:1
        bTrueValueFound = false;
        
        for dSlice=1:vdDims(3)
            for dRow=1:vdDims(1)
                if 1 == bitget(m3iBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                    bTrueValueFound = true;
                    dMaxCol = dCol;
                    break
                end
            end
            
            if bTrueValueFound
                break;
            end
        end
        
        if bTrueValueFound
            break;
        end
    end
    
    % - find min slice
    
    dMinSlice = 1;
    
    for dSlice=1:vdDims(3)
        bTrueValueFound = false;
        
        for dCol=1:vdDims(2)
            for dRow=1:vdDims(1)
                if 1 == bitget(m3iBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                    bTrueValueFound = true;
                    dMinSlice = dSlice;
                    break
                end
            end
            
            if bTrueValueFound
                break;
            end
        end
        
        if bTrueValueFound
            break;
        end
    end
    
    % - find max slice
    
    dMaxSlice = vdDims(3);
    
    for dSlice=vdDims(3):-1:1
        bTrueValueFound = false;
        
        for dCol=1:vdDims(2)
            for dRow=1:vdDims(1)
                if 1 == bitget(m3iBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                    bTrueValueFound = true;
                    dMaxSlice = dSlice;
                    break
                end
            end
            
            if bTrueValueFound
                break;
            end
        end
        
        if bTrueValueFound
            break;
        end
    end
    
    % make bounds
    
    vdRowBounds = [dMinRow, dMaxRow];
    vdColBounds = [dMinCol, dMaxCol];
    vdSliceBounds = [dMinSlice, dMaxSlice];
end

end

