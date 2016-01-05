cdef extern from "error.h" namespace "rapidjson":
    cdef enum ParseErrorCode:
        kParseErrorNone = 0,
        kParseErrorDocumentEmpty,
        kParseErrorDocumentRootNotSingular,
        kParseErrorValueInvalid,
        kParseErrorObjectMissName,
        kParseErrorObjectMissColon,
        kParseErrorObjectMissCommaOrCurlyBracket,
        kParseErrorArrayMissCommaOrSquareBracket,
        kParseErrorStringUnicodeEscapeInvalidHex,
        kParseErrorStringUnicodeSurrogateInvalid,
        kParseErrorStringEscapeInvalid,
        kParseErrorStringMissQuotationMark,
        kParseErrorStringInvalidEncoding,
        kParseErrorNumberTooBig,
        kParseErrorNumberMissFraction,
        kParseErrorNumberMissExponent,
        kParseErrorTermination,
        kParseErrorUnspecificSyntaxError

cdef extern from "error/en.h" namespace "rapidjson" nogil:
    cdef inline const char* GetParseError_En(ParseErrorCode parseErrorCode)
