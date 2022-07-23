function [i64OffsetIndex, i64Index, i32RowIndex, i32ColIndex, i32SliceIndex, i32RowOffsetIndex, i32ColOffsetIndex, i32SliceOffsetIndex, vbDimsValid] = BinOnTheFly_LoopIndicesUpdate(vi32Dims, i64OffsetIndex, i64Index, i32RowIndex, i32ColIndex, i32SliceIndex, i32RowOffsetStart, i32ColOffsetStart, i32RowOffsetIndex, i32ColOffsetIndex, i32SliceOffsetIndex, bRowLowWatch, bRowHighWatch, bColLowWatch, bColHighWatch, bSliceLowWatch, bSliceHighWatch, vbDimsValid);
    
    i64OffsetIndex = i64OffsetIndex + int64(1);
    i64Index = i64Index + int64(1);
    
    if i32RowIndex == vi32Dims(1)
        i32RowIndex = int32(1);
        i32RowOffsetIndex = i32RowOffsetStart;
        
        if bRowHighWatch
            vbDimsValid(1) = i32RowOffsetIndex <= vi32Dims(1);
        end
        
        if bRowLowWatch
            vbDimsValid(1) = false;
        end
        
        if i32ColIndex == vi32Dims(2)
            i32ColIndex = int32(1);
            i32ColOffsetIndex = i32ColOffsetStart;
            
            if bColHighWatch
                vbDimsValid(2) = i32ColOffsetIndex <= vi32Dims(2);
            end
            
            if bColLowWatch
                vbDimsValid(2) = false;
            end
            
            i32SliceIndex = i32SliceIndex + 1;
            i32SliceOffsetIndex = i32SliceOffsetIndex + 1;
            
            if bSliceHighWatch && i32SliceOffsetIndex > vi32Dims(3)
                vbDimsValid(3) = false;
            end
            
            if bSliceLowWatch && i32SliceOffsetIndex > 0
                vbDimsValid(3) = true;
            end
        else
            i32ColIndex = i32ColIndex + 1;
            i32ColOffsetIndex = i32ColOffsetIndex + 1;
            
            if bColHighWatch && i32ColOffsetIndex > vi32Dims(2)
                vbDimsValid(2) = false;
            end
            
            if bColLowWatch && i32ColOffsetIndex > 0
                vbDimsValid(2) = true;
            end
        end
    else
        i32RowIndex = i32RowIndex + 1;
        i32RowOffsetIndex = i32RowOffsetIndex + 1;
        
        if bRowHighWatch && i32RowOffsetIndex > vi32Dims(1)
            vbDimsValid(1) = false;
        end
        
        if bRowLowWatch && i32RowOffsetIndex > 0
            vbDimsValid(1) = true;
        end
    end
end

