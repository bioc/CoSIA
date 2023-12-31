# CoSIA Utility Functions

# Find the Available/Common Tissues in CoSIA for a given combination of species

#' getTissues
#'
#' @param species name of a species or multiple species that you want to get
#' available tissue list for
#'
#' @return list of tissues that are common/available among the species or
#' multiple species inputted
#' @export
#'
#' @examples
#' tissue <- getTissues(c("m_musculus"))
getTissues <- function(species) {
    # Loading CoSIAdata
    CoSIAdata_load <- function(species) {
        eh <- ExperimentHub::ExperimentHub()
        merged_CoSIAdata <- data.frame(matrix(ncol = 7, nrow = 0))
        colnames(merged_CoSIAdata) <- c(
            "Anatomical_entity_name", "Ensembl_ID",
            "Sample_size", "VST", "Experiment_ID",
            "Anatomical_entity_ID", "Species"
        )
        if (any(species == "m_musculus")) {
            mm_EH_File <- eh[["EH7859"]]
            merged_CoSIAdata <- rbind(merged_CoSIAdata, mm_EH_File)
            merged_CoSIAdata <- as.data.frame(merged_CoSIAdata)
        } else if (any(species == "r_norvegicus")) {
            rn_EH_File <- eh[["EH7860"]]
            merged_CoSIAdata <- rbind(merged_CoSIAdata, rn_EH_File)
            merged_CoSIAdata <- as.data.frame(merged_CoSIAdata)
        } else if (any(species == "d_rerio")) {
            dr_EH_File <- eh[["EH7861"]]
            merged_CoSIAdata <- rbind(merged_CoSIAdata, dr_EH_File)
            merged_CoSIAdata <- as.data.frame(merged_CoSIAdata)
        } else if (any(species == "h_sapiens")) {
            hs_EH_File <- eh[["EH7858"]]
            merged_CoSIAdata <- rbind(merged_CoSIAdata, hs_EH_File)
            merged_CoSIAdata <- as.data.frame(merged_CoSIAdata)
        } else if (any(species == "c_elegans")) {
            ce_EH_File <- eh[["EH7863"]]
            merged_CoSIAdata <- rbind(merged_CoSIAdata, ce_EH_File)
            merged_CoSIAdata <- as.data.frame(merged_CoSIAdata)
        } else if (any(species == "d_melanogaster")) {
            dm_EH_File <- eh[["EH7862"]]
            merged_CoSIAdata <- rbind(merged_CoSIAdata, dm_EH_File)
            merged_CoSIAdata <- as.data.frame(merged_CoSIAdata)
        } else {
            stop("Issue with species in CoSIAn Object. Make sure the species in the
          species argument are avalible organisms through CoSIA and are in the
          correct format.")
        }
        return(merged_CoSIAdata)
    }

    merged_CoSIAdata <- lapply(species, CoSIAdata_load)
    merged_CoSIAdata <- as.data.frame(do.call(rbind, merged_CoSIAdata))

    List_of_Tissues <- merged_CoSIAdata %>%
        dplyr::group_by(Anatomical_entity_name) %>%
        dplyr::reframe(
            Anatomical_entity_ID = unique(Anatomical_entity_ID),
            Species = unique(Species)
        )
    L <- List_of_Tissues %>% dplyr::group_by(Anatomical_entity_name)%>%
        dplyr::reframe(Frequency = table(Anatomical_entity_name))
    frequency_value <- length(species)
    common_tissue <- dplyr::filter(L, Frequency == frequency_value)
    common_tissue <- subset(common_tissue, select = -c(Frequency))
    colnames(common_tissue)[which(names(common_tissue) ==
        "Anatomical_entity_name")] <- "Common_Anatomical_Entity_Name"
    return(common_tissue)
}

#CoSIA Accessor Functions

#' viewCoSIAn Generics
#'
#' @param object CoSIAn object with all user accessible slots filled
#' @param slot_name name of output slots
#'
#' @return initializes a generic function for viewCoSIAn as preparation for
#' defining the viewCoSIAn Method 
#' @export
#'
#' @examples
#' Kidney_Genes <- CoSIAn(
#'     gene_set = c("ENSG00000008710", "ENSG00000152217"),
#'     i_species = "h_sapiens", input_id = "Ensembl_id",
#'     o_species = c(
#'         "d_melanogaster"
#'     ),
#'     output_ids = c("Ensembl_id", "Symbol"), mapping_tool = "annotationDBI",
#'     ortholog_database = "HomoloGene", map_tissues = "heart",
#'     map_species = c("d_melanogaster"), metric_type = "DS_Gene"
#' )
#' viewCoSIAn(Kidney_Genes, "converted_id")
setGeneric(
  "viewCoSIAn", 
  function(object, slot_name) standardGeneric("viewCoSIAn"))

#' viewCoSIAn
#'
#' @param object CoSIAn object with all user accessible slots filled
#' @param slot_name name of output slots
#' @return slots in CoSIAn object
#' @export
#'
#' @examples
#' Kidney_Genes <- CoSIAn(
#'     gene_set = c("ENSG00000008710", "ENSG00000152217"),
#'     i_species = "h_sapiens", input_id = "Ensembl_id",
#'     o_species = c(
#'         "d_melanogaster"
#'     ),
#'     output_ids = c("Ensembl_id", "Symbol"), mapping_tool = "annotationDBI",
#'     ortholog_database = "HomoloGene", map_tissues = "heart",
#'     map_species = c("d_melanogaster"), metric_type = "DS_Gene"
#' )
#' viewCoSIAn(Kidney_Genes, "converted_id")
setMethod(
  "viewCoSIAn", 
  signature(object = "CoSIAn"), 
  function(object, slot_name) 
    ifelse(slot_name == "converted_id", object@converted_id, 
           ifelse(slot_name == "gex", object@gex, 
                  ifelse(slot_name == "metric", object@metric, 
                         stop("User provided slot does not exist"))))
  )
