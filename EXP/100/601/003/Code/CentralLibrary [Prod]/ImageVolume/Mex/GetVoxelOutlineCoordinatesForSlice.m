function c1m2dVoxelOutlineCoordinates = GetVoxelOutlineCoordinatesForSlice(m2bSlice)

vdDims = size(m2bSlice);

m2bValidHorizontalEdges = false(vdDims(1)+3,vdDims(2)+2); % border of falses
m2bValidVerticalEdges = false(vdDims(1)+2,vdDims(2)+3);

m2bValidHorizontalEdges(2,2:end-1) = m2bSlice(1,:);
m2bValidHorizontalEdges(end-1,2:end-1) = m2bSlice(end,:);

m2bValidHorizontalEdges(3:end-2,2:end-1) = xor(m2bSlice(1:end-1,:), m2bSlice(2:end,:));

m2bValidVerticalEdges(2:end-1,2) = m2bSlice(:,1);
m2bValidVerticalEdges(2:end-1,end-1) = m2bSlice(:,end);

m2bValidVerticalEdges(2:end-1,3:end-2) = xor(m2bSlice(:,1:end-1), m2bSlice(:,2:end));

dNumValidEdges = sum(m2bValidHorizontalEdges(:)) + sum(m2bValidVerticalEdges(:));

dNumRegions = 0;

c1m2dVoxelOutlineCoordinates = cell(1,0);

for dCol = 2:vdDims(2)+1
    for dRow = 2:vdDims(1)+2
        if m2bValidHorizontalEdges(dRow,dCol)
            dNumRegions = dNumRegions + 1;
            
            [m2dCoordinates, m2bValidHorizontalEdges, m2bValidVerticalEdges]...
                = FindMaskOutlineCoordinates(m2bValidHorizontalEdges, m2bValidVerticalEdges, dRow, dCol, dNumValidEdges);
            
            m2dCoordinates(:,1) = (m2dCoordinates(:,1) - 1.5);
            m2dCoordinates(:,2) = (m2dCoordinates(:,2) - 1.5);
            
            c1m2dVoxelOutlineCoordinates{end+1} = m2dCoordinates;
        end
    end
end

end


% HELPER FUNCTIONS

function [m2dCoords, m2bValidHorizontalEdges, m2bValidVerticalEdges] = FindMaskOutlineCoordinates(m2bValidHorizontalEdges, m2bValidVerticalEdges, dStartingRow, dStartingCol, dNumValidEdges)


dNumCoords = 1;

m2dCoords = zeros(dNumValidEdges+1,2);
m2dCoords(1,:) = [dStartingRow, dStartingCol+1];

% plot(m2dCoords(1,2)-1.5,m2dCoords(1,1)-1.5,'*','MarkerEdgeColor','r');

dLastDirection = 0;

dCurrentRow = dStartingRow;
dCurrentCol = dStartingCol;

bIsHorz = true;
dLastDirection = 0;

if m2bValidVerticalEdges(dCurrentRow-1,dCurrentCol+1)
    dCurrentRow = dCurrentRow-1;
    dCurrentCol = dCurrentCol+1;
    
    m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
    
    bIsHorz = false;
    dLastDirection = 2;
elseif m2bValidVerticalEdges(dCurrentRow,dCurrentCol+1)
    dCurrentRow = dCurrentRow;
    dCurrentCol = dCurrentCol+1;
    
    m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
    
    bIsHorz = false;
    dLastDirection = 1;
elseif m2bValidHorizontalEdges(dCurrentRow,dCurrentCol+1)
    dCurrentRow = dCurrentRow;
    dCurrentCol = dCurrentCol+1;
    
    m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
    
    bIsHorz = true;
    dLastDirection = 2;
else
    error('!');
end

while ~bIsHorz || dCurrentRow ~= dStartingRow || dCurrentCol ~= dStartingCol
    dNumCoords = dNumCoords + 1;
    
    if bIsHorz
        if dLastDirection == 1            
            m2dCoords(dNumCoords,:) = [dCurrentRow, dCurrentCol];
            
            if m2bValidVerticalEdges(dCurrentRow-1,dCurrentCol)
                dCurrentRow = dCurrentRow-1;
                dCurrentCol = dCurrentCol;
                
                m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = false;
                dLastDirection = 2;
                
            elseif m2bValidVerticalEdges(dCurrentRow,dCurrentCol)
                dCurrentRow = dCurrentRow;
                dCurrentCol = dCurrentCol;
                
                m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = false;
                dLastDirection = 1;
            elseif m2bValidHorizontalEdges(dCurrentRow,dCurrentCol-1)
                dCurrentRow = dCurrentRow;
                dCurrentCol = dCurrentCol-1;
                
                m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = true;
                dLastDirection = 1;
            else
                error('!');
            end
            
            
        else
            m2dCoords(dNumCoords,:) = [dCurrentRow, dCurrentCol+1];
            
            if m2bValidVerticalEdges(dCurrentRow-1,dCurrentCol+1)
                dCurrentRow = dCurrentRow-1;
                dCurrentCol = dCurrentCol+1;
                
                m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = false;
                dLastDirection = 2;
            elseif m2bValidVerticalEdges(dCurrentRow,dCurrentCol+1)
                dCurrentRow = dCurrentRow;
                dCurrentCol = dCurrentCol+1;
                
                m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = false;
                dLastDirection = 1;
            elseif m2bValidHorizontalEdges(dCurrentRow,dCurrentCol+1)
                dCurrentRow = dCurrentRow;
                dCurrentCol = dCurrentCol+1;
                
                m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = true;
                dLastDirection = 2;
            else
                error('!');
            end
                        
            
        end
    else
        if dLastDirection == 1
            m2dCoords(dNumCoords,:) = [dCurrentRow+1, dCurrentCol];
            
            if m2bValidHorizontalEdges(dCurrentRow+1,dCurrentCol-1)
                dCurrentRow = dCurrentRow+1;
                dCurrentCol = dCurrentCol-1;
                
                m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = true;
                dLastDirection = 1;
            elseif m2bValidHorizontalEdges(dCurrentRow+1,dCurrentCol)
                dCurrentRow = dCurrentRow+1;
                dCurrentCol = dCurrentCol;
                
                m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = true;
                dLastDirection = 2;
            elseif m2bValidVerticalEdges(dCurrentRow+1,dCurrentCol)
                dCurrentRow = dCurrentRow+1;
                dCurrentCol = dCurrentCol;
                
                m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = false;
                dLastDirection = 1;
            else
                error('!');
            end
            
            
        else
            m2dCoords(dNumCoords,:) = [dCurrentRow, dCurrentCol];
            
            if m2bValidHorizontalEdges(dCurrentRow,dCurrentCol-1)
                dCurrentRow = dCurrentRow;
                dCurrentCol = dCurrentCol-1;
                
                m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = true;
                dLastDirection = 1;
            elseif m2bValidHorizontalEdges(dCurrentRow,dCurrentCol)
                dCurrentRow = dCurrentRow;
                dCurrentCol = dCurrentCol;
                
                m2bValidHorizontalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = true;
                dLastDirection = 2;
            elseif m2bValidVerticalEdges(dCurrentRow-1,dCurrentCol)
                dCurrentRow = dCurrentRow-1;
                dCurrentCol = dCurrentCol;
                
                m2bValidVerticalEdges(dCurrentRow,dCurrentCol) = false;
                
                bIsHorz = false;
                dLastDirection = 2;
            else
                error('!');
            end
            
            
        end        
    end
    
%     plot(m2dCoords(dNumCoords,2)-1.5,m2dCoords(dNumCoords,1)-1.5,'*','MarkerEdgeColor','g');
end
   
m2dCoords(dNumCoords+1,:) = m2dCoords(1,:); % complete the loop

m2dCoords = m2dCoords(1:dNumCoords+1,:);


end


