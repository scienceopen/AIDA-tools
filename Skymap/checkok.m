function [stnnames,SkMp] = checkok(SkMp)
% CHECKOK - displays time and observation site GUI for user choise.
%
% Calling:
%  [stnnames,SkMp] = checkok(SkMp);
% Input:
%  SkMp - Skymap struct, see SKYMAP
% Output:
%  stnnames - string matrix with station names
%  SkMp     - Skymap struct, see SKYMAP


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%global stardir

station = 1;
if nargin == 1
  
  checkisokstr = '[SkMp] = checkisok(SkMp);';
  if isfield(SkMp,'tid0')
    tid = SkMp.tid0;
  else
    tid = clock;
    SkMp.tid0 = tid;
  end
else
  
  checkisokstr = '[SkMp] = checkisok(SkMp);';
  tid = clock;
  SkMp.tid0 = tid;
  
end
SkMp.figchok = figure('Name','OBSERVATION DATA',...
		      'Numbertitle','off',...
		      'Position',[200,500,270,180],...
		      'resize','off',...
		      'MenuBar','none');


stnnames = SkMp.StnNames;
% $$$ stnnames{end+1} = 'Other';


SkMp.ui81 = uicontrol('units','normalized',...
		      'Style','Popup',...
		      'String',stnnames,...
		      'Value',station==1,...
		      'Position',[.05,.315,.9,.11]);


SkMp.ui815 = uicontrol('units','normalized',...
		       'Style','pushbutton',...
		       'String','long',...
		       'Position',[.05,.16+.02,.11,.11]);
SkMp.ui815 = uicontrol('units','normalized',...
		       'Style','edit',...
		       'String',num8str(SkMp.longlat(station,1)),...
		       'Position',[.18,.16+.02,.5-.015-.18,.11]);

SkMp.ui8160 = uicontrol('units','normalized',...
			'Style','pushbutton',...
			'String','lat',...
			'Position',[.515,.16+.02,.11,.11]);
SkMp.ui816 = uicontrol('units','normalized',...
		       'Style','edit',...
		       'String',num8str(SkMp.longlat(station,2)),...
		       'Position',[.64,.16+.02,.5-.015-.18,.11]);

SkMp.ui86 = uicontrol('units','normalized',...
		      'Style','pushbutton',...
		      'String','YEAR',...
		      'Position',[.05,0.825+.02,.28,.11]);
SkMp.ui86 = uicontrol('units','normalized',...
		      'Style','edit',...
		      'String',num2str(tid(1)),...
		      'Position',[.05,0.695+.02,.28,.11]);

SkMp.ui87 = uicontrol('units','normalized',...
		      'Style','pushbutton',...
		      'String','MONTH',...
		      'Position',[.36,0.825+.02,.28,.11]);
SkMp.ui87 = uicontrol('units','normalized',...
		      'Style','edit',...
		      'String',num2str(tid(2)),...
		      'Position',[.36,0.695+.02,.28,.11]);

SkMp.ui88 = uicontrol('units','normalized',...
		      'Style','pushbutton',...
		      'String','DAY',...
		      'Position',[.67,0.825+.02,.28,.11]);
SkMp.ui88 = uicontrol('units','normalized',...
		      'Style','edit',...
		      'String',num2str(tid(3)),...
		      'Position',[.67,0.695+.02,.28,.11]);

SkMp.ui89 = uicontrol('units','normalized',...
		      'Style','pushbutton',...
		      'String','HOUR',...
		      'Position',[.05,.565+.02,.28,.11]);
SkMp.ui89 = uicontrol('units','normalized',...
		      'Style','edit',...
		      'String',num2str(tid(4)),...
		      'Position',[.05,0.435+.02,.28,.11]);

SkMp.ui817 = uicontrol('units','normalized',...
		       'Style','pushbutton',...
		       'String','MIN',...
		       'Position',[.36,.565+.02,.28,.11]);
SkMp.ui817 = uicontrol('units','normalized',...
		       'Style','edit',...
		       'String',num2str(tid(5)),...
		       'Position',[.36,0.435+.02,.28,.11]);

SkMp.ui818 = uicontrol('units','normalized',...
		       'Style','pushbutton',...
		       'String','SEC',...
		       'Position',[.67,.565+.02,.28,.11]);
SkMp.ui818 = uicontrol('units','normalized',...
		       'Style','edit',...
		       'String',num2str(tid(6)),...
		       'Position',[.67,0.435+.02,.28,.11]);

SkMp.ui812 = uicontrol('units','normalized',...
		       'Style','pushbutton',...
		       'String','OK',...
		       'Position',[.045,.02+.02,.9,.11],...
		       'Callback',checkisokstr);

set(SkMp.ui81,'Callback','poschoice(SkMp)');