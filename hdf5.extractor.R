hdf5.extractor = function(files,
                          dirname,
                          import.messages = TRUE,
                          logs = TRUE) {
    # This funciton takes three arguments:
    # 'files'             which is a vector or filenames to be processed and
    # 'events'            which is a vector of events to be extracted from the HDF5 file
    # 'import.messages'   which is a boolean - do you want event messages and event logs imported?
    # 'logs'              which is a boolean - do you want to get vectors with all DF names AND a general log of import?
    
    
    # To use this function:
    # source("/path/to/file/edf.extractor.R"
    
    library('rhdf5')
    
    # Close all open conections
    h5closeAll()
    
    # TODO
    # Add exception handling for the source/install of the rhdf5
    
    # For easier handling later on I would create lists of imported DFs
    # This can make looping easier in analysis:
    hdf5.import.df  = c()     # Log for all DFs with ET data (events)
    hdf5.import.evt = c()     # Log for all MessageEvent DFs created
    hdf5.mapping = matrix(ncol = 3, nrow = length(files))
    
    for (i in 1:length(files)) { files[i] = paste(dirname, files.hdf5[i], sep = '/')}

    events = c("/eyetracker/BinocularEyeSampleEvent")
    
    for (f in 1:length(files)) {
        ##### Import ET events
        for (e in 1:length(events)) {
            tmp.name = strsplit(events[e], "/")
            tmp.name = tmp.name[[1]][length(tmp.name[[1]])]
            tmp.data = h5read(files[f], paste("/data_collection/events", events[e], sep = ""))
            
            if (f < 10){
                # Adds leading 0 to the ss id no
                tmp.df.name = sprintf("ss0%i.%s", f, tmp.name)
                tmpm = sprintf("file %s extracted to ss0%i.%s", files[f], f, tmp.name)
            }
            else {
                tmp.df.name = sprintf("ss%i.%s", f, tmp.name)
                tmpm = sprintf("file %s extracted to ss%i.%s", files[f], f, tmp.name)
            }
            
            message(tmpm)
            
            # save the DF to the GLOBAL ENVI
            assign(tmp.df.name, tmp.data, envir = .GlobalEnv)
            
            # add to mapping matrix
            hdf5.mapping[f,1] = files[f]
            hdf5.mapping[f,2] = tmp.df.name
            

            # append to log
            if (logs == TRUE) {
                hdf5.import.df  = append(hdf5.import.df, tmp.df.name)
            }
            
            ##### Import messages
            if (import.messages == TRUE) {
                tmp.msgs = h5read(files[f],
                                  "/data_collection/events/experiment/MessageEvent")
            }
            
            # Save as GLOBAL
            if (f < 10){
                assign(sprintf("ss0%i.MessageEvent", f), tmp.msgs, envir = .GlobalEnv)
                tmpe = sprintf("file %s extracted to ss0%i.MessageEvent", files[f], f)
                hdf5.mapping[f,3] = sprintf("ss0%i.MessageEvent", f)
            }
            else {
                assign(sprintf("ss%i.MessageEvent", f), tmp.msgs, envir = .GlobalEnv)
                tmpe = sprintf("file %s extracted to ss%i.MessageEvent", files[f], f)
                hdf5.mapping[f,3] = sprintf("ss%i.MessageEvent", f)
            }
            
            message(tmpe)
        
            
            
            # append to log
            if (logs == TRUE) {
                if (f < 10){
                    hdf5.import.evt = append(hdf5.import.evt,
                                             sprintf("ss0%i.MessageEvent", f))
                }
                else{
                    hdf5.import.evt = append(hdf5.import.evt,
                                             sprintf("ss%i.MessageEvent", f))
                }
                
            }
        }
        
    }

    
    # Save log vectors if needed
    if (logs == TRUE) {
        assign("hdf5.import.df", hdf5.import.df, envir = .GlobalEnv)
        assign("hdf5.import.evt", hdf5.import.evt, envir = .GlobalEnv)
        assign("hdf5.mapping", hdf5.mapping, envir = .GlobalEnv)
    }
    
    H5close()
}