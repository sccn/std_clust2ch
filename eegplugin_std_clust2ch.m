% eegplugin_std_clust2ch() - This is a plugin for back-projecting IC
%                            cluster to scalp channels.

% Author: Makoto Miyakoshi, JSPS/SCCN,INC,UCSD
% History
% 07/25/2018 Makoto. Developed into std_clust2ch.
% 05/22/2015 ver 1.4 by Makoto. Renamed ('backprojection' is wrong, it's a forward projection)
% 01/08/2015 ver 1.3 by Makoto. Major update.
% 06/28/2013 ver 1.2 by Makoto. submenu = uimenu( std, 'label', 'Backproj from clst to chan', 'userdata', 'startup:off;study:on');
% 01/10/2013 ver 1.1 by Makoto. Minor changes.
% 10/26/2012 ver 1.0 by Makoto. Created.

% Copyright (C) 2012, Makoto Miyakoshi JSPS/SCCN,INC,UCSD
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



function eegplugin_std_clust2ch( fig, try_strings, catch_strings);

 vers = '1.0';
    if nargin < 3
        error('eegplugin_std_clust2ch requires 3 arguments');
    end
    
% create menu
std = findobj(fig, 'tag', 'study');
submenu = uimenu( std, 'label', 'clust2ch', 'userdata', 'startup:off;study:on');

% add new submenu
uimenu( submenu, 'label', 'Precompute', 'callback', 'std_precompute_clust2ch', 'userdata', 'startup:off;study:on');
uimenu( submenu, 'label', 'Plot',       'callback', 'std_plot_clust2ch',       'userdata', 'startup:off;study:on', 'separator','on');
