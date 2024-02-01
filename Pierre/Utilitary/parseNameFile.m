function [animal, condition] = parseNameFile(path)
    splitted_path = split(path, '\');
    infos = splitted_path(end);
    splitted_infos = split(infos, '_');
    animal = splitted_infos{1};
    condition = splitted_infos{2};
end

