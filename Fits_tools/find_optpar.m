function optpar = find_optpar(obs,OPS)
% FIND_OPTPAR - search the optpar data-base for best OPTPAR
% 
% WARNING - OUTDATED FUNCTION!
%
% Calling:
% optpar = find_optpar(obs,OPS)
% 
% Input:
%   OBS - observation-struct as returned from TRY_TO_BE_SMART
%   OPS - options-struct. Currently with fields 'verb' for
%         verbosity: [ q | q1 | quiet ] for quiet, [q[2-9]] for
%         silent, and anystring else for less quiet operation,
%         default 'q'; and 'fix_missaligned' [{1}|0], default is to
%         prompt the user for action when no good optimal optpar is
%         found
% Output:
%   OPTPAR - optical parameters to use with functions in CAMERA
%
% See also TRY_TO_BE_SMART CAMERA

%   Copyright � 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global all_opt_acc_mtr

optpar = [-1 1 0 0 0 0 0 .35 3 -1]; %%% just some bad default value

fix_missalign = 1;
verbosity = 0;
if nargin > 1 && ~isempty(OPS) && isfield(OPS,'verb')
  verbosity = OPS.verb;
end
if nargin > 1 && ~isempty(OPS) && isfield(OPS,'fix_missalign')
  fix_missalign = OPS.fix_missalign;
end

if nargin == 0
  % no input argument return an OPS
  optpar.verb = 0;
  optpar.fix_missalign = 1;
  return
end

% first time search for all *.acc files.
if isempty(all_opt_acc_mtr)
  
  load Sall2.acc
  all_opt_acc_mtr = Sall2;
  
end


po = all_opt_acc_mtr(obs.station==all_opt_acc_mtr(:,1),:);
if isempty(po)
  
  optpar = [-1 1 0 0 0 0 0 .35 3 0];
  warning(['No camera calibration files for station ',...
        num2str(obs.station),' were found.'])
  warning('Returning default GUESS: [-1 1 0 0 0 0 0 .35 3 0]')
  warning('Please proceed with care. Actions have to be taken to get the')
  warning('Projections, triangulations and tomography to work')
  return
  
end
% Then optpars from valid/close dates
I = find(po(:,4) <= date2juldate(obs.time) & ...
         date2juldate(obs.time) <= po(:,5) );
if isempty(I)
  if verbosity > -1
    disp(['No camera calibration valid at ',num2str(obs.time(1)),'-',...
          num2str(obs.time(2)),'-',num2str(obs.time(2)),...
          ' for station ',num2str(obs.station),' were found.'])
  end
else
  po = po(I,:);
end

% Calculate the nominal line-of-sight direction of the observation
if ~isempty(obs.az) % either from AZ ZE
  
  e_h(1) = sin(obs.ze*pi/180)*sin(obs.az*pi/180);
  e_h(2) = sin(obs.ze*pi/180)*cos(obs.az*pi/180);
  e_h(3) = cos(obs.ze*pi/180);
  
else % Or from alpha beta
  
  e_h(3) = cos(obs.alpha*pi/180)*cos(obs.beta*pi/180);
  e_h(2) = sin(obs.beta*pi/180);
  e_h(3) = sin(obs.alpha*pi/180)*cos(obs.beta*pi/180);
  
end

maxval = 0;
% Search for the most parallel
for i = 1:size(po,1),
  
  e_acc(1) = sin(po(i,3)*pi/180)*sin(po(i,2)*pi/180);
  e_acc(2) = sin(po(i,3)*pi/180)*cos(po(i,2)*pi/180);
  e_acc(3) = cos(po(i,3)*pi/180);
  
  if (dot(e_h,e_acc)>maxval)
    most_paralell_indx = i;
    maxval = dot(e_h,e_acc);
  end
    
end

resort = [7:14 6 15];
optpar = po(most_paralell_indx,resort);
if ( maxval >= cos(.2*pi/180) )
  % We're within 0.2 degrees 
  
  if verbosity >= 2
    disp(['Station ',num2str(obs.station),' Obs az and ze: ',num2str([obs.az obs.ze])])
    disp(['Az, Ze, Optpar ',num2str(po(most_paralell_indx,[2 3 resort])) ])
  end
  
elseif ( maxval >= cos(.5*pi/180) )
  
  optpar = po(most_paralell_indx,resort);
  
  if verbosity >= 0
    warning(['Optical missalignment > 0.2 degrees for station' ...
             ' ',num2str(obs.station)])
    warning(' ')
    warning(['Azimuth and zenith from image header: ',num2str([obs.az obs.ze])])
    warning(['Closest Azimuth and zenith found: ', ...
             num2str(po(most_paralell_indx,[2 3]))])
    warning(' ')
    
  end
else
  
  if fix_missalign
    disp(['Optical missalignment > 0.5 degrees for station' ...
          ' ',num2str(obs.station)])
    disp(' ')
    disp(['Azimuth and zenith from image header: ',num2str([obs.az obs.ze])])
    disp(['Closest Azimuth and zenith found: ', ...
          num2str(po(most_paralell_indx,[2 3]))])
    disp(' ')
    disp('Now there are the following options:')
    disp('1. Accept the optical parameters found.')
    disp(['2. Calculate the rotation from the image header and use the' ...
          ' other optical parameters found.'])
    disp('3. Manually give the nessecary parameters')
    op_choise = in_def2('What action to take? ',1);
    switch op_choise
     case 1,
      optpar = po(most_paralell_indx,resort);
     case 2,
      optpar = po(most_paralell_indx,resort);
      if ~isempty(obs.alpha)
        
        optpar(3:5) = [obs.alpha, obs.beta, 0];
        
      else
        
        [alfa,beta] = fitaeta_2_alfabeta(obs.az,obs.ze);
        optpar(3:5) = [alfa, beta, 0];
        
      end
     case 3
      
      optpar = in_def2('optpar = ',1:10);
      
     otherwise
      
      error('Gomenasai, I dont understand what you want me to do')
      
    end
  elseif verbosity >= -1
    disp(['Optical missalignment > 0.5 degrees for station' ...
          ' ',num2str(obs.station)])
    disp(' ')
    disp(['Azimuth and zenith from image header: ',num2str([obs.az obs.ze])])
    disp(['Closest Azimuth and zenith found: ', ...
          num2str(po(most_paralell_indx,[2 3]))])
    optpar = po(most_paralell_indx,resort);
  end
end
