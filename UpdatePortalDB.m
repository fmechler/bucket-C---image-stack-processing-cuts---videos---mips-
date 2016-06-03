function UpdatePortalDB(brainName, portalBrainName)

%% 
% function UpdatePortalDB(brainName, portalBrainName)
%
%  Updates brains records in 'mbaDB' (the portal data base) from records of the brain in 'MBAStorageDB' (the data base inside the fire wall associated with the Internal Viewer / Navigator
%
%  CALLS: MySQL read/write functions
%  Written by Amit Mukherjee 2014
if nargin == 1
	bnum = [];
	balpha = [];
	for i=1:numel(brainName)
		if isdigit1(brainName(i))
			bnum = [bnum, brainName(i)];
		else
			balpha = [balpha, brainName(i)];
		end
	end
	if strcmp(balpha,'PMD')
		bnum = str2num(bnum);
		portalBrainName = sprintf('MouseBrain_%04d',bnum);
	else
		bnum = str2num(bnum);
		portalBrainName = sprintf('MouseBrain_%s%d',balpha,bnum);
	end
end

SectionOnDisk = scanDiskForFiles(brainName);
fprintf('Found %d sections on disk\n', numel(SectionOnDisk));

javaaddpath('mysql-connector-java-5.1.20-bin.jar');
connStorage = database('MBAStorageDB','Mitramba1DBUser','123456','com.mysql.jdbc.Driver','jdbc:mysql://mitramba1.cshl.edu:3306/MBAStorageDB');
if ~isconnection(connStorage)
	fprintf('Cannot connect to the storage database\n');
	return;
end
fprintf('Connected to MBAStorageDB\n');

% query storage BD and get information
res1 = fetch(connStorage,['SELECT IFNULL(tracer,"(no tracer)"), IFNULL(BregmaSection,0), IFNULL(InjectionSection,0) ',...
			'FROM Navigator_brain JOIN Navigator_injection ON Navigator_brain.name=Navigator_injection.brain_id ', ...
			'WHERE name="', brainName ,'" LIMIT 1']);
res2 = fetch(connStorage, ['SELECT IFNULL(ara_id,0), IFNULL(x,0), IFNULL(y,0), IFNULL(z,0) ', ...
			'FROM Navigator_brain LEFT JOIN Navigator_injectionlocation ON Navigator_injectionlocation.number=Navigator_brain.ActualInjection ', ...
			' WHERE Navigator_brain.name="', brainName , '" LIMIT 1']);
res3 = fetch(connStorage,['SELECT filename, modeIndex, label ', ...
			'FROM Navigator_section ', ...
			'WHERE brain_id = "', brainName , '"']);

close(connStorage);

tracer=res1{1};
bregmaSection=res1{2};
injectionSection=res1{3};
regionCode=res2{1};
xCoordinate=res2{2};
yCoordinate=res2{3};
zCoordinate=res2{4};

fprintf('\ttracer = %s\n\tbregmaSection = %d\n\tinjectionSection = %d\n\tregionCode = %s\n\txCoordinate = %d\n\tyCoordinate = %d\n\tzCoordinate = %d\n', ...
	tracer,bregmaSection,injectionSection,regionCode,xCoordinate,yCoordinate,zCoordinate);
	
if abs(xCoordinate) > 20 || abs(yCoordinate) > 20 || abs(zCoordinate) > 20
 	xCoordinate = xCoordinate/1000;
	yCoordinate = yCoordinate/1000;
	zCoordinate = zCoordinate/1000;
end

missingSectionInDB = 0;
for i=1:numel(SectionOnDisk)
	found = 0;
	for j=1:size(res3,1)
		if strcmp(SectionOnDisk{i}.name, res3{j,1}) == 1
			SectionOnDisk{i}.modeIndex = res3{j,2};
			SectionOnDisk{i}.label = res3{j,3};
			found = 1;
			break;
		end
	end 
	if found == 0
		fprintf('Section %s on disk has no DB record\n', SectionOnDisk{i}.name);
		missingSectionInDB = missingSectionInDB+1;
%	else 
%		fprintf('OK %s\n', SectionOnDisk{i}.name);
	end
end

if missingSectionInDB > 0
	fprintf('Number of Sections (detected on disk) is missing on DB : %d\n', missingSectionInDB);
	return;
end
fprintf('All section records are located on storage DB\n');

Nseries = 0;
Fseries = 0;
IHCseries = 0;
sampleSectionMode = SectionOnDisk{floor(numel(SectionOnDisk)/2)}.modeIndex; 
distToInjectionSection = 10000;
for i=1:numel(SectionOnDisk)
	if strcmp(SectionOnDisk{i}.label,'N')
		Nseries=Nseries+1;
	elseif strcmp(SectionOnDisk{i}.label,'F')
		Fseries=Fseries+1;
		if (distToInjectionSection > abs(SectionOnDisk{i}.modeIndex - double(injectionSection)))
			distToInjectionSection = abs(SectionOnDisk{i}.modeIndex - double(injectionSection));
			sampleSectionMode = SectionOnDisk{i}.modeIndex;
		end
	elseif strcmp(SectionOnDisk{i}.label,'IHC')
		IHCseries=IHCseries+1;
		if (distToInjectionSection > abs(SectionOnDisk{i}.modeIndex - double(injectionSection)))
			distToInjectionSection = abs(SectionOnDisk{i}.modeIndex - double(injectionSection));
			sampleSectionMode = SectionOnDisk{i}.modeIndex;
		end		
	end
end
fprintf('Summary of section to be posted\n\tNSeries %d\n\tFseris %d\n\tHCseries %d\n',Nseries,Fseries,IHCseries);
%keyboard;
fprintf('Connecting to portalDB now\n');
%host = "143.48.220.13", user = "mitralab", passwd = "bungt0wn", db = "mbaDB"
connPortal = database('mbaDB','mitralab','bungt0wn','com.mysql.jdbc.Driver','jdbc:mysql://143.48.220.13:3306/mbaDB');

if ~isconnection(connPortal)
	fprintf('Cannot connect to the portal database\n');
	return;
end	
fprintf('Connection successful\n');

%set(connPortal,'AutoCommit','off');

%create brain_id
qBrain = fetch(connPortal,['SELECT id FROM seriesbrowser_brain WHERE name="',portalBrainName,'"']);
if isempty(qBrain) 
	%insert brain
	fprintf('Inserting new brain with name %s\n', portalBrainName);  
	fastinsert(connPortal,'seriesbrowser_brain',{'seriesbrowser_brain.name'},{portalBrainName});
	qBrain = fetch(connPortal,['SELECT id FROM seriesbrowser_brain WHERE seriesbrowser_brain.name="',portalBrainName,'"']);
else
	fprintf('Brain with name %s already exists.\n', portalBrainName);	
end
brain_id = qBrain{1};

qLab = fetch(connPortal,'SELECT id from seriesbrowser_laboratory WHERE seriesbrowser_laboratory.name = "Mitra"');
lab_id = qLab{1};

qSecPlane = fetch(connPortal,'SELECT id FROM seriesbrowser_sectioningplane WHERE seriesbrowser_sectioningplane.desc = "Coronal"');
secPlane_id = qSecPlane{1};

%other default values
pixelResolution = 0.49;
sectionThickness = 20;
sectionThicknessUnit = 'um';
isReviewed = 0; 	%tinyint(1) 
isRestricted = 1; 	%tinyint(1)
numQCSections = 0;    %int(11) 
isAuxiliary = 0;
keepForAnalysis = 0;
doNotPublish = 0;

%create series_id

if Nseries > 0
	jp2BitDepth = 8;
	labelMethodName='N';
	q = fetch(connPortal,['SELECT id from seriesbrowser_labelmethod WHERE seriesbrowser_labelmethod.labelMethodName = "N"']);
	labelMethod_id = q{1};
	desc = [portalBrainName, ' N'];
	q = fetch(connPortal,'SELECT * from seriesbrowser_imagemethod WHERE seriesbrowser_imagemethod.name = "Brightfield"');
	imageMethod_id = q{1};
	
	q = fetch(connPortal,['SELECT id FROM seriesbrowser_series WHERE seriesbrowser_series.brain_id = ',num2str(brain_id),' AND seriesbrowser_series.labelMethod_id = ' num2str(labelMethod_id) ]);
	if isempty(q)
		fprintf('Inserting new series with label N\n');
		
		fastinsert(connPortal,'seriesbrowser_series', {'seriesbrowser_series.desc','seriesbrowser_series.brain_id','seriesbrowser_series.labelMethod_id', 'seriesbrowser_series.lab_id', 'seriesbrowser_series.imageMethod_id','seriesbrowser_series.sectioningPlane_id', 'seriesbrowser_series.pixelResolution', 'seriesbrowser_series.sectionThickness', 'seriesbrowser_series.sectionThicknessUnit', 'seriesbrowser_series.isReviewed', 'seriesbrowser_series.isRestricted', 'seriesbrowser_series.numQCSections', 'seriesbrowser_series.isAuxiliary','seriesbrowser_series.keepForAnalysis','seriesbrowser_series.doNotPublish'}, {desc, brain_id, labelMethod_id, lab_id, imageMethod_id, secPlane_id, pixelResolution, sectionThickness, sectionThicknessUnit, 0, 1, numQCSections, 0, 0, 0 });
		
		%INSERT INTO seriesbrowser_series SET seriesbrowser_series.desc="MouseBrain_LAT0001 N", seriesbrowser_series.brain_id=1910, seriesbrowser_series.labelMethod_id=1, seriesbrowser_series.lab_id=1, seriesbrowser_series.imageMethod_id=1, seriesbrowser_series.sectioningPlane_id=2, seriesbrowser_series.pixelResolution= 0.49, seriesbrowser_series.sectionThickness=20, seriesbrowser_series.sectionThicknessUnit="um", seriesbrowser_series.isReviewed=0, seriesbrowser_series.numQCSections=0, seriesbrowser_series.isAuxiliary=0 , seriesbrowser_series.keepForAnalysis=0;
		
		%fastinsert(connPortal,'seriesbrowser_series', {'seriesbrowser_series.desc','seriesbrowser_series.brain_id','seriesbrowser_series.labelMethod_id', 'seriesbrowser_series.lab_id','seriesbrowser_series.imageMethod_id','seriesbrowser_series.sectioningPlane_id','seriesbrowser_series.pixelResolution', 'seriesbrowser_series.sectionThickness','seriesbrowser_series.sectionThicknessUnit','seriesbrowser_series.isReviewed','seriesbrowser_series.isRestricted', 'seriesbrowser_series.numQCSections','seriesbrowser_series.isAuxiliary','seriesbrowser_series.keepForAnalysis','seriesbrowser_series.doNotPublish'}, {'MouseBrain_LAT0001 N', 1910, 1, 1, 1, 2, 0.49, 20, 'um', 0, 1, 0, 0, 0 });
		
		
		q = fetch(connPortal,['SELECT id FROM seriesbrowser_series WHERE seriesbrowser_series.brain_id = ',num2str(brain_id), ' AND seriesbrowser_series.labelMethod_id = ' num2str(labelMethod_id) ]);	
	end
	series_id = q{1};
	
	%now update every section
	for i=1:numel(SectionOnDisk)
		if strcmp(SectionOnDisk{i}.label,'N') == 0
			continue;
		end
		sectionYCoordinate = (bregmaSection - SectionOnDisk{i}.modeIndex) *2*sectionThickness / 1000;
		sectionName = [portalBrainName,'_Section_',labelMethodName,'_',sprintf('%04d',SectionOnDisk{i}.modeIndex)];
		q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
		if ~isempty(q)
			fprintf('Section already posted on the portal : %s\n',sectionName);
			continue;
		end
		
		fprintf('Inserting new Section %s\n',sectionName);
		fastinsert(connPortal,'seriesbrowser_section',{'seriesbrowser_section.isVisible', 'seriesbrowser_section.series_id', 'seriesbrowser_section.name', 'seriesbrowser_section.sectionOrder', 'seriesbrowser_section.pngPathLow', 'seriesbrowser_section.jp2Path', 'seriesbrowser_section.jp2FileSize', 'seriesbrowser_section.jp2BitDepth', 'seriesbrowser_section.y_coord'}, {1, series_id, sectionName, int32(SectionOnDisk{i}.modeIndex),SectionOnDisk{i}.pngPathlow, SectionOnDisk{i}.jp2Path, SectionOnDisk{i}.jp2FileSize,jp2BitDepth ,sectionYCoordinate});
		
		q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
		section_id = q{1};
		identifier = ['MouseBrain/',num2str(section_id)];
		
		q = fetch(connPortal, [ 'SELECT id FROM seriesbrowser_dataresolver WHERE identifier = "', identifier,'"' ]);
		if ~isempty(q)
			fprintf('Section already exist on dataresolver the portal : %s\n',sectionName);
			continue;
		end
		
		fastinsert(connPortal, 'seriesbrowser_dataresolver', {'seriesbrowser_dataresolver.identifier', 'seriesbrowser_dataresolver.imageFile', 'seriesbrowser_dataresolver.section_id'}, {identifier, SectionOnDisk{i}.jp2Path, section_id});
		
		if (SectionOnDisk{i}.modeIndex == sampleSectionMode) 
			update(connPortal,'seriesbrowser_series', {'seriesbrowser_series.sampleSection_id'}, {section_id}, [' where  seriesbrowser_series.id = ', num2str(series_id)]);
		end
	end
end


if IHCseries > 0
	%keyboard;
	jp2BitDepth = int32(8);
	labelMethodName='IHC';
	q = fetch(connPortal,['SELECT id from seriesbrowser_labelmethod WHERE seriesbrowser_labelmethod.labelMethodName = "IHC"']);
	labelMethod_id = q{1};
	desc = [portalBrainName, ' HC'];
	q = fetch(connPortal,'SELECT id from seriesbrowser_imagemethod WHERE seriesbrowser_imagemethod.name = "Brightfield"');
	imageMethod_id = q{1};
	
	q = fetch(connPortal,['SELECT id FROM seriesbrowser_series WHERE brain_id = ',num2str(brain_id),' AND labelMethod_id = ', num2str(labelMethod_id) ]);
	if isempty(q)
		fprintf('Inserting new series with label IHC\n');
		
		fastinsert(connPortal,'seriesbrowser_series', {'seriesbrowser_series.desc','seriesbrowser_series.brain_id','seriesbrowser_series.labelMethod_id', 'seriesbrowser_series.lab_id', 'seriesbrowser_series.imageMethod_id','seriesbrowser_series.sectioningPlane_id', 'seriesbrowser_series.pixelResolution', 'seriesbrowser_series.sectionThickness', 'seriesbrowser_series.sectionThicknessUnit', 'seriesbrowser_series.isReviewed', 'seriesbrowser_series.isRestricted', 'seriesbrowser_series.numQCSections', 'seriesbrowser_series.isAuxiliary','seriesbrowser_series.keepForAnalysis','seriesbrowser_series.doNotPublish'}, {desc, brain_id, labelMethod_id, lab_id, imageMethod_id, secPlane_id, pixelResolution, sectionThickness, sectionThicknessUnit, 0, 1, numQCSections, 0, 0, 0 });
		q = fetch(connPortal,['SELECT id FROM seriesbrowser_series WHERE brain_id = ',num2str(brain_id), ' AND labelMethod_id = ' num2str(labelMethod_id )]);	
	end
	series_id = q{1};
	
	q = fetch(connPortal, ['SELECT id FROM seriesbrowser_region WHERE code = "', regionCode,'"' ]);
	region_id = q{1};
		
	q = fetch(connPortal, ['SELECT id FROM seriesbrowser_tracer WHERE name = "', tracer,'"']);
	tracer_id = q{1};
	
	%keyboard;
	q = fetch(connPortal, ['SELECT id FROM seriesbrowser_injection WHERE series_id = ', num2str(series_id)] );
	if isempty(q)
		fprintf('Inserting new Injection\n');	
		fastinsert(connPortal, 'seriesbrowser_injection', {'seriesbrowser_injection.series_id', 'seriesbrowser_injection.region_id', 'seriesbrowser_injection.region_actual_id', 'seriesbrowser_injection.tracer_id', 'seriesbrowser_injection.volume', 'seriesbrowser_injection.volumeUnits', 'seriesbrowser_injection.x_coord', 'seriesbrowser_injection.y_coord', 'seriesbrowser_injection.z_coord', 'seriesbrowser_injection.x_coord_actual','seriesbrowser_injection.y_coord_actual','seriesbrowser_injection.z_coord_actual'}, {series_id, region_id, region_id, tracer_id, 0,'ml', xCoordinate, yCoordinate, zCoordinate, xCoordinate, yCoordinate, zCoordinate});
	end
	
	%now update every section
	for i=1:numel(SectionOnDisk)
		if strcmp(SectionOnDisk{i}.label,'IHC') == 0
			continue;
		end
		sectionYCoordinate = (bregmaSection - SectionOnDisk{i}.modeIndex) *2*sectionThickness / 1000;
		sectionName = [portalBrainName,'_Section_',labelMethodName,'_',sprintf('%04d',SectionOnDisk{i}.modeIndex)];
		q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
		if ~isempty(q)
			fprintf('Section already posted on the portal : %s\n',sectionName);
			continue;
		end
		
		fprintf('Inserting new Section %s\n',sectionName);
		fastinsert(connPortal,'seriesbrowser_section',{'seriesbrowser_section.isVisible', 'seriesbrowser_section.series_id', 'seriesbrowser_section.name', 'seriesbrowser_section.sectionOrder', 'seriesbrowser_section.pngPathLow', 'seriesbrowser_section.jp2Path', 'seriesbrowser_section.jp2FileSize', 'seriesbrowser_section.jp2BitDepth', 'seriesbrowser_section.y_coord'}, {1, series_id, sectionName, int32(SectionOnDisk{i}.modeIndex),SectionOnDisk{i}.pngPathlow, SectionOnDisk{i}.jp2Path, SectionOnDisk{i}.jp2FileSize,jp2BitDepth ,sectionYCoordinate});
		
		q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
		section_id = q{1};
		identifier = ['MouseBrain/',num2str(section_id)];
		
		q = fetch(connPortal, [ 'SELECT id FROM seriesbrowser_dataresolver WHERE identifier = "', identifier,'"' ]);
		if ~isempty(q)
			fprintf('Section already exist on dataresolver the portal : %s\n',sectionName);
			continue;
		end
		
		fastinsert(connPortal, 'seriesbrowser_dataresolver', {'seriesbrowser_dataresolver.identifier', 'seriesbrowser_dataresolver.imageFile', 'seriesbrowser_dataresolver.section_id'}, {identifier, SectionOnDisk{i}.jp2Path,section_id});

		if (SectionOnDisk{i}.modeIndex == sampleSectionMode)
			fprintf('adding sample section\n'); 		
			update(connPortal,'seriesbrowser_series', {'seriesbrowser_series.sampleSection_id'}, {section_id}, [' where  seriesbrowser_series.id = ', num2str(series_id)]);
		end
	end
	
	
end
if Fseries > 0
	jp2BitDepth = 16;
	labelMethodName='F';
	q = fetch(connPortal,['SELECT id from seriesbrowser_labelmethod WHERE seriesbrowser_labelmethod.labelMethodName = "F"']);
	labelMethod_id = q{1};
	desc = [portalBrainName, ' F'];
	q = fetch(connPortal,'SELECT * from seriesbrowser_imagemethod WHERE seriesbrowser_imagemethod.name = "Fluorescent"');
	imageMethod_id = q{1};
	
	q = fetch(connPortal,['SELECT id FROM seriesbrowser_series WHERE brain_id = ',num2str(brain_id),' AND labelMethod_id = ' num2str(labelMethod_id) ]);
	if isempty(q)
		fprintf('Inserting new series with label F\n');
		%keyboard;
		fastinsert(connPortal,'seriesbrowser_series', {'seriesbrowser_series.desc','seriesbrowser_series.brain_id','seriesbrowser_series.labelMethod_id', 'seriesbrowser_series.lab_id', 'seriesbrowser_series.imageMethod_id','seriesbrowser_series.sectioningPlane_id', 'seriesbrowser_series.pixelResolution', 'seriesbrowser_series.sectionThickness', 'seriesbrowser_series.sectionThicknessUnit', 'seriesbrowser_series.isReviewed', 'seriesbrowser_series.isRestricted', 'seriesbrowser_series.numQCSections', 'seriesbrowser_series.isAuxiliary','seriesbrowser_series.keepForAnalysis','seriesbrowser_series.doNotPublish'}, {desc, brain_id, labelMethod_id, lab_id, imageMethod_id, secPlane_id, pixelResolution, sectionThickness, sectionThicknessUnit, 0, 1, numQCSections, 0, 0, 0 });
		q = fetch(connPortal,['SELECT id FROM seriesbrowser_series WHERE brain_id = ',num2str(brain_id), ' AND labelMethod_id = ' num2str(labelMethod_id) ]);	
	end
	series_id = q{1};
	
	q = fetch(connPortal, ['SELECT id FROM seriesbrowser_region WHERE code = "', regionCode,'"' ]);
	region_id = q{1};
		
	q = fetch(connPortal, ['SELECT id FROM seriesbrowser_tracer WHERE name = "', tracer,'"']);
	tracer_id = q{1};
	
	q = fetch(connPortal, ['SELECT id FROM seriesbrowser_injection WHERE series_id = ', num2str(series_id)] );
	if isempty(q)
		fprintf('Inserting new Injection\n');
		%keyboard;		
		fastinsert(connPortal, 'seriesbrowser_injection', {'seriesbrowser_injection.series_id', 'seriesbrowser_injection.region_id', 'seriesbrowser_injection.region_actual_id', 'seriesbrowser_injection.tracer_id', 'seriesbrowser_injection.volume', 'seriesbrowser_injection.volumeUnits', 'seriesbrowser_injection.x_coord', 'seriesbrowser_injection.y_coord', 'seriesbrowser_injection.z_coord', 'seriesbrowser_injection.x_coord_actual','seriesbrowser_injection.y_coord_actual','seriesbrowser_injection.z_coord_actual'}, {series_id, region_id, region_id, tracer_id, 0,'ml', xCoordinate, yCoordinate, zCoordinate, xCoordinate, yCoordinate, zCoordinate});
	end
	
	%now update every section
	for i=1:numel(SectionOnDisk)
		if strcmp(SectionOnDisk{i}.label,'F') == 0
			continue;
		end
		sectionYCoordinate = (bregmaSection - SectionOnDisk{i}.modeIndex) *2*sectionThickness / 1000;
		sectionName = [portalBrainName,'_Section_',labelMethodName,'_',sprintf('%04d',SectionOnDisk{i}.modeIndex)];
		q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
		if ~isempty(q)
			fprintf('Section already posted on the portal : %s\n',sectionName);
			continue;
		end
		
		fprintf('Inserting new Section %s\n',sectionName);
		fastinsert(connPortal,'seriesbrowser_section',{'seriesbrowser_section.isVisible', 'seriesbrowser_section.series_id', 'seriesbrowser_section.name', 'seriesbrowser_section.sectionOrder', 'seriesbrowser_section.pngPathLow', 'seriesbrowser_section.jp2Path', 'seriesbrowser_section.jp2FileSize', 'seriesbrowser_section.jp2BitDepth', 'seriesbrowser_section.y_coord'}, {1, series_id, sectionName, int32(SectionOnDisk{i}.modeIndex),SectionOnDisk{i}.pngPathlow, SectionOnDisk{i}.jp2Path, SectionOnDisk{i}.jp2FileSize,jp2BitDepth ,sectionYCoordinate});
		
		q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
		section_id = q{1};
		identifier = ['MouseBrain/',num2str(section_id)];
		
		q = fetch(connPortal, [ 'SELECT id FROM seriesbrowser_dataresolver WHERE identifier = "', identifier,'"' ]);
		if ~isempty(q)
			fprintf('Section already exist on dataresolver the portal : %s\n',sectionName);
			continue;
		end
		
		fastinsert(connPortal, 'seriesbrowser_dataresolver', {'seriesbrowser_dataresolver.identifier', 'seriesbrowser_dataresolver.imageFile', 'seriesbrowser_dataresolver.section_id'}, {identifier, SectionOnDisk{i}.jp2Path ,section_id});

		if (SectionOnDisk{i}.modeIndex == sampleSectionMode) 
			fprintf('adding sample section\n');  
			update(connPortal,'seriesbrowser_series', {'seriesbrowser_series.sampleSection_id'}, {section_id}, [' where  seriesbrowser_series.id = ', num2str(series_id)]);
		end
	end
	
	
end


%commit(connPortal);
%rollback(connPortal);

close(connPortal);



function SectionOnDisk = scanDiskForFiles(brainName)
%the code uses ssh for remote directory scans, you must set up ssh authentication for passwordless login first. 
username = 'ferenc';

cmd = ['ssh ',username,'@mitragpu1 ls -l /brainimg/',brainName,'/*.jp2  | awk ''{ print $9":"$5 }'' '];
%cmd = ['ssh ',username,'@mitraweb2 ls /mnt/bluearc/mitradata2/PORTALJP2/',brainName,'/*.jp2  | awk ''{ print $9":"$5 }'' '];

[status, FileNameData] = system(cmd);
if status ~= 0
	fprintf('The brain is not yet on portal directory\n');
	return;
end
k=0;
m=1;
for i=1:numel(FileNameData)-3
	if (strcmp(FileNameData(i:i+3),'.jp2') == 1),
		j = i;
	elseif (FileNameData(i)=='/'),
		s = i;
	elseif (FileNameData(i)==':')
		c = i;
	elseif int32(FileNameData(i)) == 10
		k=k+1;
		SectionOnDisk{k}.name = FileNameData(s+1:j-1);
		SectionOnDisk{k}.pngPathlow = [FileNameData(m:j-1),'.jpg'];
		SectionOnDisk{k}.jp2Path = [FileNameData(m:c-1)];		
		SectionOnDisk{k}.jp2FileSize = str2double(FileNameData(c+1:i));
		c = 0; s = 0; j = 0;
		m = i+1;
	end
end
if c > s
	k=k+1;
	SectionOnDisk{k}.name = FileNameData(s+1:j-1);
	SectionOnDisk{k}.pngPathlow = [FileNameData(m:j-1),'.jpg'];
	SectionOnDisk{k}.jp2Path = [FileNameData(m:c-1)];		
	SectionOnDisk{k}.jp2FileSize = str2double(FileNameData(c+1:i));
end

function b = isdigit1(c)
if (int32(c)>=48 && int32(c)<=57)
	b = 1;
	return;
end
b = 0;
