function maxCollisions = addHashTable(list, songidnum)
    global hashtable;
    hashTableSize = size(hashtable, 1);
    maxCollisions = 0;

    fprintf('[DEBUG] Adding hashes for Song ID: %d\n', songidnum);

    for m = 1:size(list, 1)
        hash = convert2hash(list(m, 3), list(m, 4), list(m, 2) - list(m, 1), hashTableSize);

        if hash > 0 && hash <= hashTableSize
            if isempty(hashtable{hash, 1})
                hashtable{hash, 1} = songidnum; 
                hashtable{hash, 2} = list(m, 1);
            else
                hashtable{hash, 1} = [hashtable{hash, 1}, songidnum];
                hashtable{hash, 2} = [hashtable{hash, 2}, list(m, 1)];
            end

            fprintf('[DEBUG] Hash: %d | Added Song ID: %d | Time: %d\n', hash, songidnum, list(m, 1));
        else
            warning('Hash value %d is out of bounds.', hash);
        end
    end
end
