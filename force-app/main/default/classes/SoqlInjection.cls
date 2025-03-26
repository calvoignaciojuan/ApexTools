public with sharing class SoqlInjection {

    public static void typesOfinjectionsTesting(){

      String queryHacker = 'x%\' OR Name LIKE \'';
      system.debug('Input Query queryHacker: ' + queryHacker);

      system.debug('-------------------  fullQuery_vulnerable  ----------------------------------');
      String fullQuery_vulnerable   = 'Select id, Name from Account where Name like \'%' + queryHacker + '%\'';
      system.debug('fullQuery_vulnerable: ' + fullQuery_vulnerable);
      system.debug('fullQuery_vulnerable query records size: ' + dataBase.query(fullQuery_vulnerable).size());

      system.debug('-------------------  fullQuery_bindVariable  -------------------------------');
      String queryInput = '%' + queryHacker + '%';
      String fullQuery_bindVariable = 'Select id, Name from Account where Name like :queryInput';
      system.debug('fullQuery_bindVariable: ' + fullQuery_bindVariable);
      system.debug('fullQuery_bindVariable query records size: ' + dataBase.query(fullQuery_bindVariable).size());                                 

      system.debug('-------------------  fullQuery_scapeSingleQuotes  -------------------------------');
      String scapeSingleQuotesQuery = String.escapeSingleQuotes(queryHacker);
      String fullQuery_scapeSingleQuotesQuery   = 'Select id, Name from Account where Name like \'%' + scapeSingleQuotesQuery + '%\'';
      system.debug('fullQuery_scapeSingleQuotesQuery: ' + fullQuery_scapeSingleQuotesQuery);
      system.debug('fullQuery_scapeSingleQuotesQuery query records size: ' + dataBase.query(fullQuery_scapeSingleQuotesQuery).size()); 
      }   
}