function dMaxDist = FindMaxDistanceBetweenCoordinates(m2dCoordinates)
%m2dCoordiantes should be m x n where m (# rows) is the number of
%coordinates and n (# cols) is the dimensionality of the coordinate system

dNumCoords = size(m2dCoordinates,1);

dMaxDist = 0;

for dCoordIndex=1:dNumCoords
    vdCoord = m2dCoordinates(dCoordIndex,:);
    
    for dSearchIndex=dCoordIndex+1:dNumCoords
        dCurDist = sum((vdCoord - m2dCoordinates(dSearchIndex,:)).^2);
                   
        dMaxDist = max(dCurDist, dMaxDist);        
    end
end

dMaxDist = sqrt(dMaxDist);

end

