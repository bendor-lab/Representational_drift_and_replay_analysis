function [animal, condition, day] = parseNameFile(filename)
    splitted_name = split(filename, '\');
    infos = splitted_name(end);
    splitted_infos = split(infos, '_');
    animal = splitted_infos{1};
    condition = splitted_infos{end};
    day = splitted_infos{2};
end

