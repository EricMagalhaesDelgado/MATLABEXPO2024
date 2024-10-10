classdef DialogAppExample_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        SampleSizeLabel        matlab.ui.control.Label
        DropDown               matlab.ui.control.DropDown
        EditField              matlab.ui.control.Spinner
        ColormapDropDownLabel  matlab.ui.control.Label
    end


    properties (Access = private)
        Container
        isDocked = false
        MainApp % Main app 
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function StartupFcn(app, mainapp, sz, c)
            
            % Store main app in property
            app.MainApp = mainapp;
            
            % Place side by side with the main window
            if ~app.isDocked
                app.UIFigure.Position(1) = sum(mainapp.UIFigure.Position([1,3]))+5;
                app.UIFigure.Position(2) = mainapp.UIFigure.Position(2);
            end

            % Update UI with input values
            app.EditField.Value = sz;
            app.DropDown.Value = c;
            
        end

        % Value changed function: DropDown, EditField
        function EditFieldValueChanged(app, event)
            
            % Call main app's public function
            updateplot(app.MainApp, app.EditField.Value, app.DropDown.Value);
            
        end

        % Close request function: UIFigure
        function DialogAppCloseRequest(app, event)
            
            % Enable the Plot Options button in main app, if the app is
            % still open
            if isvalid(app.MainApp)
                app.MainApp.OptionsButton.Enable = "on";
            end
            
            % Delete the dialog box 
            delete(app)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, Container)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            if isempty(Container)
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.AutoResizeChildren = 'off';
                app.UIFigure.Position = [1107 290 340 340];
                app.UIFigure.Name = 'Options';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @DialogAppCloseRequest, true);

                app.Container = app.UIFigure;

            else
                if ~isempty(Container.Children)
                    delete(Container.Children)
                end

                app.UIFigure  = ancestor(Container, 'figure');
                app.Container = Container;
                app.isDocked  = true;
            end

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Container);
            app.GridLayout.ColumnWidth = {'1x', 90};
            app.GridLayout.RowHeight = {22, 22};
            app.GridLayout.RowSpacing = 5;

            % Create ColormapDropDownLabel
            app.ColormapDropDownLabel = uilabel(app.GridLayout);
            app.ColormapDropDownLabel.Layout.Row = 2;
            app.ColormapDropDownLabel.Layout.Column = 1;
            app.ColormapDropDownLabel.Text = 'Colormap';

            % Create EditField
            app.EditField = uispinner(app.GridLayout);
            app.EditField.Limits = [2 1000];
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Layout.Row = 1;
            app.EditField.Layout.Column = 2;
            app.EditField.Value = 35;

            % Create DropDown
            app.DropDown = uidropdown(app.GridLayout);
            app.DropDown.Items = {'Parula', 'Jet', 'Winter', 'Cool'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.DropDown.Layout.Row = 2;
            app.DropDown.Layout.Column = 2;
            app.DropDown.Value = 'Parula';

            % Create SampleSizeLabel
            app.SampleSizeLabel = uilabel(app.GridLayout);
            app.SampleSizeLabel.Layout.Row = 1;
            app.SampleSizeLabel.Layout.Column = 1;
            app.SampleSizeLabel.Text = 'Sample Size';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DialogAppExample_exported(Container, varargin)

            % Create UIFigure and components
            createComponents(app, Container)

            % Execute the startup function
            runStartupFcn(app, @(app)StartupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            if app.isDocked
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
