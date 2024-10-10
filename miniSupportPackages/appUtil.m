classdef (Abstract) appUtil
    
    methods (Static = true)
        function htmlSource = jsBackDoorHTMLSource()
            htmlSource = fullfile(fileparts(mfilename('fullpath')), 'jsBackDoor', 'Container.html');
        end

        %-----------------------------------------------------------------%
        function executionMode = ExecutionMode(hFigure)
            % "In MATLAB R2024, the containers for the desktop and web app 
            % versions of an app are the files 'cefComponentContainer.html' 
            % and 'webAppsComponentContainer.html,' respectively.

            % >> struct(struct(hFigure).Controller).PeerModelInfo.URL
            % 'https://127.0.0.1:31517/toolbox/matlab/uitools/uifigureappjs/cefComponentContainer.html?channel=/uifigure/45562d91-459d-4a9e-bafc-4f51c6940e09&websocket=on&syncMode=MF0ViewModel&snc=FV5YKZ' (MATLAB)
            % 'https://127.0.0.1:31517/toolbox/matlab/uitools/uifigureappjs/cefComponentContainer.html?channel=/uifigure/04fb3193-a2cb-405a-9eac-8e3e38486454&websocket=on&syncMode=MF0ViewModel&snc=JOZ8GB' (MATLAB Runtime)
            % 'http://df6963612dtn:9988/services/static/24.1/toolbox/compiler/mdwas/client/session/webAppContainer.html?MDWAS-Connection-Id=5d9ffe85-3824-419b-bedb-1ad678c5ac4b'                            (MATLAB WebServer - DEPLOY)
            % 'https://fiscalizacao.anatel.gov.br/services/static/24.1/toolbox/compiler/mdwas/client/session/webAppContainer.html?MDWAS-Connection-Id=2240b1cf-15c0-4894-9ee0-6b52508f1b44'                  (MATLAB WebServer)

            % >> struct(struct(struct(hFigure).Controller).PlatformHost).ReleaseHTMLFile
            % 'cefComponentContainer.html'     (MATLAB, e MATLAB Runtime)
            % 'webAppsComponentContainer.html' (MATLAB WebServer)
            
            htmlAppContainer = struct(struct(struct(hFigure).Controller).PlatformHost).ReleaseHTMLFile;
            if contains(htmlAppContainer, 'webApp', 'IgnoreCase', true)
                executionMode = 'webApp';
            else
                if isdeployed
                    executionMode = 'desktopStandaloneApp';
                else
                    executionMode = 'MATLABEnvironment';
                end
            end
        end

        %-----------------------------------------------------------------%
        function winPosition(hFigure)
            % Place the app window in the center of the largest monitor.

            mainMonitor = get(0, 'MonitorPositions');
            [~, idx]    = max(mainMonitor(:,3));
            mainMonitor = mainMonitor(idx,:);

            xPosition   = mainMonitor(1)+round((mainMonitor(3)-hFigure.Position(3))/2);
            yPosition   = mainMonitor(2)+round((mainMonitor(4)+18-hFigure.Position(4))/2);

            hFigure.Position(1:2)  = [xPosition, yPosition];
        end

        %-----------------------------------------------------------------%
        function hPanel = modalDockContainer(jsBackDoor, containerType, varargin)
            % Create a panel as a dock container for .M files generated through 
            % exported .MLAPPs (following the procedure shown).

            arguments
                jsBackDoor    (1,1) matlab.ui.control.HTML
                containerType char {mustBeMember(containerType, {'Popup', 'Popup+CloseButton'})} = 'Popup'
            end

            arguments (Repeating)
                varargin
            end

            switch containerType
                case 'Popup'
                    Padding   = varargin{1};
                    winWidth  = varargin{2};
                    winHeight = varargin{3};                    

                    hFigure = ancestor(jsBackDoor, 'figure');
                    hGrid   = uigridlayout(hFigure, ColumnWidth={'1x', winWidth, '1x'}, RowHeight={'1x', winHeight, '1x'}, Padding=Padding*[1,1,1,1], ColumnSpacing=0, RowSpacing=0);

                    hPanel  = uipanel(hGrid, Title='', AutoResizeChildren='off');
                    hPanel.Layout.Row = 2;
                    hPanel.Layout.Column = 2;
                    
                    drawnow
                    ccTools.compCustomizationV2(jsBackDoor, hGrid, 'backgroundColor', 'rgba(255,255,255,0.65)')

                    hPanelDataTag = struct(hPanel).Controller.ViewModel.Id;
                    sendEventToHTMLSource(jsBackDoor, "panelDialog", struct('componentDataTag', hPanelDataTag))

                case 'Popup+CloseButton'
                    Padding = varargin{1};
                    
                    hFigure = ancestor(jsBackDoor, 'figure');
                    hGrid   = uigridlayout(hFigure, ColumnWidth={'1x', 16}, RowHeight={20, '1x'}, Padding=Padding*[1,1,1,1], ColumnSpacing=0, RowSpacing=0);

                    hPanel  = uipanel(hGrid, Title='', AutoResizeChildren='off');
                    hPanel.Layout.Row = [1,2];
                    hPanel.Layout.Column = [1,2];                    
                    
                    hImage  = uiimage(hGrid, ImageSource='Delete_32Gray.png', ImageClickedFcn=@(~,~)DeleteModalContainer);
                    hImage.Layout.Row = 1;
                    hImage.Layout.Column = 2;
                    hImage.ImageC
                    
                    drawnow
                    ccTools.compCustomizationV2(jsBackDoor, hGrid, 'backgroundColor', 'rgba(255,255,255,0.65)')
            end

            hPanel.DeleteFcn = @(~,~)DeleteModalContainer();
            function DeleteModalContainer()
                delete(hGrid)
            end
        end
    end
end

