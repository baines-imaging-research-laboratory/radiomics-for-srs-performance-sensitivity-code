function bool = doesStructContainField(struct, fieldname)
%bool = doesStructContainField(struct, fieldname)

bool = false;

fieldsInStruct = fieldnames(struct);

for i=1:length(fieldsInStruct)
    if strcmp(fieldsInStruct{i}, fieldname)
        bool = true;
        break;
    end
end

end

