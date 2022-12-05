function vdCentreOfMass = GetCentreOfMassForMask(m3bMask)

dNumPoints = 0;

dRowSum = 0;
dColSum = 0;
dSliceSum = 0;

vdDims = [size(m3bMask,1), size(m3bMask,2), size(m3bMask,3)];

for dSlice=1:vdDims(3)
    for dCol=1:vdDims(2)
        for dRow=1:vdDims(1)
            if m3bMask(dRow,dCol,dSlice)
                dNumPoints = dNumPoints + 1;
                dRowSum = dRowSum + dRow;
                dColSum = dColSum + dCol;                
                dSliceSum = dSliceSum + dSlice;
            end
        end
    end
end

vdCentreOfMass = [dRowSum dColSum dSliceSum] ./ dNumPoints; 

end

