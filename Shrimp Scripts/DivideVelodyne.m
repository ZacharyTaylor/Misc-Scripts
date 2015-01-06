function [] = DivideVelodyne()
%VELODYNECSVTOMAT converts from massive velodyne input block to small
%easy to read ply files
%generate input with
% cat raw/*.bin | velodyne-to-csv -q --db ./db.xml --fields=x,y,z,intensity,t,scan,id > velodyne.csv

%block size to load file in (prevents running out of ram)
blockSize = 20000000;
%size of line of vel information in bytes
lineSize = 45;
%size of line of output ply info in bytes
outLineSize = 19;

fileName = 'velodyne.bin';
fidIn = fopen(fileName,'r');

xyzStore = [];
intStore = [];
timeStore = [];
idStore = [];
validStore = [];

timestamps = zeros(1000000,1);
tIdx = 0;

run = true;

while run
    %read a block of data
    x = fread(fidIn, blockSize, '*double', (lineSize-8));
    fseek(fidIn, (-lineSize*length(x) + 8), 'cof');
    y = fread(fidIn, blockSize, '*double', (lineSize-8));
    fseek(fidIn, (-lineSize*length(x) + 8), 'cof');
    z = fread(fidIn, blockSize, '*double', (lineSize-8));
    fseek(fidIn, (-lineSize*length(x) + 8), 'cof');
    
    intensity = fread(fidIn, blockSize, '*uint32', (lineSize-4));
    fseek(fidIn, (-lineSize*length(x) + 4), 'cof');
    scanId = fread(fidIn, blockSize, '*uint32', (lineSize-4));
    fseek(fidIn, (-lineSize*length(x) + 4), 'cof');
    beamId = fread(fidIn, blockSize, '*uint32', (lineSize-4));
    fseek(fidIn, (-lineSize*length(x) + 4), 'cof');
    
    time = fread(fidIn, blockSize, '*uint64', (lineSize-8));
    fseek(fidIn, (-lineSize*length(x) + 8), 'cof');
    
    valid = fread(fidIn, blockSize, '*uint8', (lineSize-1));
    fseek(fidIn,1,'cof');
    
    if(blockSize ~= length(time))
        run = false;
    end

    scanId = scanId(1:length(x));
    %find number of scans it covers
    minScan = min(scanId);
    maxScan = max(scanId);
    
    %break if id messed up
    if(maxScan > 10000)
        break;
    end
    
    %for each scan
    for i = minScan:maxScan
        %get positions of elements for that scan
        pos = (scanId == i);
        
        %get xyz values
        xyzOut = [x(pos),y(pos),z(pos)];
        %get intensity
        intOut = intensity(pos);
        %get time
        timeOut = time(pos);
        %get laser id
        idOut = beamId(pos);
        %get valid points
        validOut = valid(pos);
               
        %add on elements from last block
        if(i == minScan)
            xyzOut = [xyzOut; xyzStore];
            intOut = [intOut; intStore];
            timeOut = [timeOut; timeStore];
            idOut = [idOut; idStore];
            validOut = [validOut; validStore];
        end
        
        %store unfinished blocks
        if(i == maxScan)
            xyzStore = xyzOut;
            intStore = intOut;
            timeStore = timeOut;
            idStore = idOut;
            validStore = validOut;
        else
               
            %construct name
            name = ['Scan' sprintf('%05d',i) '.ply'];

            %output
            [ fid, Msg ] = fopen (name, 'w', 'ieee-be');

            if ( fid == -1 )
            error(Msg);
            end

            fprintf(fid,'ply\nformat binary_big_endian 1.0\n');
            fprintf(fid,'element vertex %u\n',size(xyzOut,1));
            fprintf(fid,'property float x\n');
            fprintf(fid,'property float y\n');
            fprintf(fid,'property float z\n');
            fprintf(fid,'property uchar intensity\n');
            fprintf(fid,'property uint timeOffset\n');
            fprintf(fid,'property uchar beamID\n');
            fprintf(fid,'property uchar valid\n');
            fprintf(fid,'end_header\n');

            fseek(fid,-outLineSize+4,'eof');
            fwrite(fid,single(xyzOut(:,1)),'float',outLineSize-4);
            fseek(fid, (-outLineSize*length(xyzOut(:,1)) + 4), 'cof');
            fwrite(fid,single(xyzOut(:,2)),'float',outLineSize-4);
            fseek(fid, (-outLineSize*length(xyzOut(:,2)) + 4), 'cof');
            fwrite(fid,single(xyzOut(:,3)),'float',outLineSize-4);

            fseek(fid, (-outLineSize*length(xyzOut(:,3)) + 1), 'cof');
            fwrite(fid,uint8(intOut),'uchar',outLineSize-1);

            fseek(fid, (-outLineSize*length(intOut) + 4), 'cof');
            fwrite(fid,uint32(timeOut - min(timeOut)),'uint32',outLineSize-4);

            fseek(fid, (-outLineSize*length(timeOut) + 1), 'cof');
            fwrite(fid,uint8(idOut),'uchar',outLineSize-1);

            fseek(fid, (-outLineSize*length(idOut) + 1), 'cof');
            fwrite(fid,uint8(validOut),'uchar',outLineSize-1);

            fclose(fid);
             
            %write info to timestamp file
            tIdx = tIdx+1;
            timestamps(tIdx) = min(timeOut);

            fprintf('outputing scan %i\n',i);
        end
    end
    
end

%output timestamps
fidOut = fopen('timestamps.bin','w');
frewind(fidOut);
fwrite(fidOut,timestamps(1:tIdx), 'uint64');
fclose(fidOut);

end

