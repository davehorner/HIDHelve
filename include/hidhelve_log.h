#include <boost/log/trivial.hpp>
#define LOG_TRACE(LOGTEXT)  BOOST_LOG_TRIVIAL(trace)   << LOGTEXT;
#define LOG_DEBUG(LOGTEXT)  BOOST_LOG_TRIVIAL(debug)   << LOGTEXT;
#define LOG_INFO(LOGTEXT)   BOOST_LOG_TRIVIAL(info)    << LOGTEXT;
#define LOG_WARN(LOGTEXT)   BOOST_LOG_TRIVIAL(warning) << LOGTEXT;
#define LOG_ERROR(LOGTEXT)  BOOST_LOG_TRIVIAL(error)   << LOGTEXT;
#define LOG_FATAL(LOGTEXT)  BOOST_LOG_TRIVIAL(fatal)   << LOGTEXT;
