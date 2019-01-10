﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возвращает структуру полей адреса для программного формирования адреса.
//
// Результат:
//    Структура - поля адреса:
//        * Представление    - Строка - текстовое представление адреса по административно-территориальному делению.
//        * МуниципальноеПредставление - Строка - текстовое представление адреса по муниципальному делению.
//        * ТипАдреса        - Строка - основной тип адреса (только для адресов РФ).
//                                      Варианты: "Муниципальный", "Административно-территориальный".
//        * Страна           - Строка - текстовое представление страны.
//        * КодСтраны        - Строка - код страны по ОКСМ.
//        * Индекс           - Строка - почтовый индекс.
//        * КодРегиона       - Строка - код региона РФ.
//        * Регион           - Строка - текстовое представление региона РФ.
//        * РегионСокращение - Строка - сокращение региона.
//        * Округ            - Строка - текстовое представление округа (устарело).
//        * ОкругСокращение  - Строка - сокращение округа (устарело).
//        * Район            - Строка - текстовое представление района у адресов по административно-территориальному делению.
//        * РайонСокращение  - Строка - сокращение района у адресов по административно-территориальному делению.
//        * МуниципальныйРайон - Строка - текстовое представление муниципального района у адресов по муниципальному делению.
//        * МуниципальныйРайонСокращение - Строка - сокращение муниципального района у адресов по муниципальному делению.
//        * Город            - Строка - текстовое представление города у адресов по административно-территориальному делению.
//        * ГородСокращение  - Строка - сокращение города  у адресов по административно-территориальному делению.
//        * Поселение            - Строка - текстовое представление поселения у адресов по муниципальному делению.
//        * ПоселениеСокращение  - Строка - сокращение поселения у адресов по муниципальному делению.
//        * ВнутригородскойРайон - Строка - текстовое представление внутригородского района.
//        * ВнутригородскойРайонСокращение  - Строка - сокращение внутригородского района.
//        * НаселенныйПункт  - Строка - текстовое представление населенного пункта.
//        * НаселенныйПунктСокращение - Строка - сокращение населенного пункта.
//        * Территория            - Строка - текстовое представление территории.
//        * ТерриторияСокращение  - Строка - сокращение территории.
//        * Улица            - Строка - текстовое представление улицы.
//        * УлицаСокращение  - Строка - сокращение улицы.
//        * ДополнительнаяТерритория - Строка - текстовое представление дополнительной территории (устарело).
//        * ДополнительнаяТерриторияСокращение - Строка - сокращение дополнительной территории (устарело).
//        * ЭлементДополнительнойТерритории - Строка - текстовое представление элемента дополнительной территории (устарело).
//        * ЭлементДополнительнойТерриторииСокращение - Строка - сокращение элемента дополнительной территории (устарело).
//        * Здание - Структура - структура с информацией о здании адреса.
//            ** ТипЗдания - Строка  - тип объекта адресации адреса РФ согласно приказу Минфина России от 5.11.2015 г. N
//                                     171н.
//            ** Номер - Строка  - текстовое представление номера дома (только для адресов РФ).
//        * Корпуса - Массив - содержит структуры(поля структуры: ТипКорпуса, Номер) с перечнем корпусов адреса.
//        * Помещения - Массив - содержит структуры(поля структуры: ТипПомещения, Номер) с перечнем помещений адреса.
//        * ИдентификаторАдресногоОбъекта - УникальныйИдентификатор - Идентификационный код последнего адресного объекта
//                                        в иерархи адреса. Например, для адреса: Москва г., Дмитровское ш., д.9 это
//                                        будет идентификатор улицы.
//        * ИдентификаторДома - УникальныйИдентификатор - Идентификационный код дома(строения) адресного объекта.
//        * Идентификаторы - Структура - Идентификаторы адресных объектов адреса.
//            ** РегионИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор региона.
//            ** РайонИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор района.
//            ** МуниципальныйРайонИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор муниципального района.
//            ** ГородИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор города.
//            ** ПоселениеИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор поселения.
//            ** ВнутригородскойРайонИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор
//                                                                                           внутригородского района.
//            ** НаселенныйПунктИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор населенного пункта.
//            ** ТерриторияИдентификатор - УникальныйИдентификатор, Неопределено - идентификатор территории.
//            ** УлицаИдентификатор      - УникальныйИдентификатор, Неопределено - идентификатор улица.
//        * КодыКЛАДР           - Структура - Коды КЛАДР, если установлен параметр КодыКЛАДР.
//           ** Регион          - Строка    - Код КЛАДР региона.
//           ** Район           - Строка    - Код КЛАДР район.
//           ** Город           - Строка    - Код КЛАДР города.
//           ** НаселенныйПункт - Строка    - Код КЛАДР населенного пункта.
//           ** Улица           - Строка    - Код КЛАДР улица.
//        * ДополнительныеКоды  - Структура - Коды ОКТМО, ОКТМО, ОКАТО, КодИФНСФЛ, КодИФНСЮЛ, КодУчасткаИФНСФЛ, КодУчасткаИФНСЮЛ.
//        * Комментарий - Строка - комментарий к адресу.
//
Функция ПоляАдреса() Экспорт
	
	Результат = Новый Структура;
	
	Результат.Вставить("ТипАдреса"                 , "");
	Результат.Вставить("Комментарий"               , "");
	
	Результат.Вставить("Представление"             , "");
	Результат.Вставить("МуниципальноеПредставление", "");
	
	Результат.Вставить("Страна"   , "");
	Результат.Вставить("КодСтраны", "");
	Результат.Вставить("Индекс"   , "");
	
	Результат.Вставить("КодРегиона"                               , "");
	Результат.Вставить("Регион"                                   , "");
	Результат.Вставить("РегионСокращение"                         , "");
	Результат.Вставить("Округ"                                    , "");
	Результат.Вставить("ОкругСокращение"                          , "");
	Результат.Вставить("Район"                                    , "");
	Результат.Вставить("РайонСокращение"                          , "");
	Результат.Вставить("МуниципальныйРайон"                       , "");
	Результат.Вставить("МуниципальныйРайонСокращение"             , "");
	Результат.Вставить("Город"                                    , "");
	Результат.Вставить("ГородСокращение"                          , "");
	Результат.Вставить("Поселение"                                , "");
	Результат.Вставить("ПоселениеСокращение"                      , "");
	Результат.Вставить("ВнутригородскойРайон"                     , "");
	Результат.Вставить("ВнутригородскойРайонСокращение"           , "");
	Результат.Вставить("НаселенныйПункт"                          , "");
	Результат.Вставить("НаселенныйПунктСокращение"                , "");
	Результат.Вставить("Территория"                               , "");
	Результат.Вставить("ТерриторияСокращение"                     , "");
	Результат.Вставить("Улица"                                    , "");
	Результат.Вставить("УлицаСокращение"                          , "");
	Результат.Вставить("ДополнительнаяТерритория"                 , "");
	Результат.Вставить("ДополнительнаяТерриторияСокращение"       , "");
	Результат.Вставить("ЭлементДополнительнойТерритории"          , "");
	Результат.Вставить("ЭлементДополнительнойТерриторииСокращение", "");
	
	Здание = Новый Структура;
	Здание.Вставить("ТипЗдания", "");
	Здание.Вставить("Номер"    , "");
	Результат.Вставить("Здание", Здание);
	
	Результат.Вставить("Корпуса"  , Новый Массив);
	Результат.Вставить("Помещения", Новый Массив);
	
	Результат.Вставить("ИдентификаторАдресногоОбъекта", Неопределено);
	Результат.Вставить("ИдентификаторДома"            , Неопределено);
	
	Идентификаторы = Новый Структура;
	Идентификаторы.Вставить("РегионИдентификатор"              , Неопределено);
	Идентификаторы.Вставить("РайонИдентификатор"               , Неопределено);
	Идентификаторы.Вставить("МуниципальныйРайонИдентификатор"  , Неопределено);
	Идентификаторы.Вставить("ГородИдентификатор"               , Неопределено);
	Идентификаторы.Вставить("ПоселениеИдентификатор"           , Неопределено);
	Идентификаторы.Вставить("ВнутригородскойРайонИдентификатор", Неопределено);
	Идентификаторы.Вставить("НаселенныйПунктИдентификатор"     , Неопределено);
	Идентификаторы.Вставить("ТерриторияИдентификатор"          , Неопределено);
	Идентификаторы.Вставить("УлицаИдентификатор"               , Неопределено);
	Результат.Вставить("Идентификаторы", Идентификаторы);
	
	ДополнительныеКоды = Новый Структура;
	ДополнительныеКоды.Вставить("ОКТМО"           , "");
	ДополнительныеКоды.Вставить("ОКАТО"           , "");
	ДополнительныеКоды.Вставить("КодИФНСФЛ"       , "");
	ДополнительныеКоды.Вставить("КодИФНСЮЛ"       , "");
	ДополнительныеКоды.Вставить("КодУчасткаИФНСФЛ", "");
	ДополнительныеКоды.Вставить("КодУчасткаИФНСЮЛ", "");
	Результат.Вставить("ДополнительныеКоды", ДополнительныеКоды);
	
	КодыКЛАДР = Новый Структура;
	КодыКЛАДР.Вставить("Регион"         , "");
	КодыКЛАДР.Вставить("Район"          , "");
	КодыКЛАДР.Вставить("Город"          , "");
	КодыКЛАДР.Вставить("НаселенныйПункт", "");
	КодыКЛАДР.Вставить("Улица"          , "");
	Результат.Вставить("КодыКЛАДР", КодыКЛАДР);
	
	Возврат Результат;
	
КонецФункции

// Возвращает структуру контактной информации по типу.
// Для получения полей адреса следует использовать РаботаСАдресамиКлиентСервер.ПоляАдреса.
//
// Параметры:
//  ТипКИ - ПеречислениеСсылка.ТипыКонтактнойИнформации	 - тип контактной информации.
//  ФорматАдреса - Строка - Тип возвращаемой структуры в зависимости от формата адреса: "КЛАДР" или "ФИАС" информацию.
// 
// Возвращаемое значение:
//  Структура - пустая структура контактной информации, ключи - имена полей, значения поля.
//
Функция СтруктураКонтактнойИнформацииПоТипу(ТипКИ, ФорматАдреса = "КЛАДР") Экспорт
	
	Если ТипКИ = ПредопределенноеЗначение("Перечисление.ТипыКонтактнойИнформации.Адрес") Тогда
		Возврат СтруктураПолейАдреса(ФорматАдреса);
	ИначеЕсли ТипКИ = ПредопределенноеЗначение("Перечисление.ТипыКонтактнойИнформации.Телефон") Тогда
		Возврат УправлениеКонтактнойИнформациейКлиентСервер.СтруктураПолейТелефона();
	Иначе
		Возврат Новый Структура;
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ОсновнаяСтрана() Экспорт
	Возврат ПредопределенноеЗначение("Справочник.СтраныМира.Россия");
КонецФункции

Функция ЭтоМуниципальныйАдрес(ТипАдреса) Экспорт
	Возврат СтрСравнить(ТипАдреса, МуниципальныйАдрес()) = 0;
КонецФункции

Функция ЭтоОсновнаяСтрана(Страна) Экспорт
	Возврат СтрСравнить(ОсновнаяСтрана(), Страна) = 0;
КонецФункции

Функция АдминистративноТерриториальныйАдрес() Экспорт
	Возврат "Административно-территориальный";
КонецФункции

Функция МуниципальныйАдрес() Экспорт
	Возврат "Муниципальный";
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Описание национальных полей структуры контактной информации для хранения ее в формате JSON.
// Основной список полей определяется в одноименной функции общего модуля УправлениеКонтактнойИнформациейКлиентСервер.
//
//    ТипКонтактнойИнформации  - ПеречислениеСсылка.ТипыКонтактнойИнформации -
//                                Тип контактной информации, определяющий состав полей контактной информации.
//
// Возвращаемое значение:
//   Структура - Поля контактной информации добавленные к основным полям:
//     Для типа контактной информации адрес:
//     * ID - Строка -  Идентификационный код последнего адресного объекта в иерархи адреса.
//     * AddressType - Строка - установленный пользователем тип адреса(только для адресов РФ).
//                              Варианты: "Муниципальный", "Административно-территориальный".
//     * AreaCode - Строка - код региона РФ.
//     * AreaID - Строка - идентификатор региона.
//     * District - Строка - представление района у адресов по административно-территориальному делению.
//     * DistrictType - Строка - сокращение района у адресов по административно-территориальному делению.
//     * DistrictID - Строка - идентификатор региона у адресов по административно-территориальному делению.
//     * MunDistrict - Строка - представление муниципального района у адресов по муниципальному делению.
//     * MunDistrictType - Строка - сокращение муниципального района у адресов по муниципальному делению.
//     * MunDistrictID - Строка - идентификатор муниципального района у адресов по муниципальному делению.
//     * CityID - Строка - идентификатор муниципального города у адресов по административно-территориальному делению.
//     * Settlement - Строка - представление поселения у адресов по муниципальному делению.
//     * SettlementType - Строка - сокращение поселения у адресов по муниципальному делению.
//     * SettlementID - Строка - идентификатор поселения.
//     * CityDistrict - Строка - представление внутригородского района.
//     * CityDistrictType - Строка - сокращение внутригородского района.
//     * CityDistrictID - Строка - идентификатор внутригородского района.
//     * Territory - Строка - представление территории.
//     * TerritoryType - Строка - сокращение территории.
//     * TerritoryID - Строка - идентификатор территории.
//     * Locality - Строка - представление населенного пункта.
//     * LocalityType - Строка - сокращение населенного пункта.
//     * LocalityID - Строка - идентификатор населенного пункта.
//     * StreetID - Строка - идентификатор улицы.
//     * HouseType - Строка - тип дома, владения.
//     * HouseNumber - Строка - номер дома, владения.
//     * HouseID - Строка - идентификатор дома.
//     * Buildings - Массив - содержит структуры(поля структуры: type, number) с перечнем корпусов (строений) адреса.
//     * Apartments - Массив - содержит структуры(поля структуры: type, number) с перечнем помещений адреса.
//     * CodeKLADR - Строка - Код КЛАДР.
//     * OKTMO - Строка - Код ОКТМО.
//     * OKATO - Строка - Код ОКАТО.
//     * IFNSFLCode - Строка - Код ИФНСФЛ.
//     * IFNSULCode - Строка - Код ИФНСЮЛ.
//     * IFNSFLAreaCode - Строка - Код участка ИФНСФЛ.
//     * IFNSULAreaCode - Строка - Код участка ИФНСЮЛ.
//
Функция ОписаниеНовойКонтактнойИнформации(Знач ТипКонтактнойИнформации) Экспорт
	
	Если ТипЗнч(ТипКонтактнойИнформации) <> Тип("ПеречислениеСсылка.ТипыКонтактнойИнформации") Тогда
		ТипКонтактнойИнформации = "";
	КонецЕсли;
	
	Результат = УправлениеКонтактнойИнформациейКлиентСервер.ОписаниеНовойКонтактнойИнформации(ТипКонтактнойИнформации);
	
	Если ТипКонтактнойИнформации = ПредопределенноеЗначение("Перечисление.ТипыКонтактнойИнформации.Адрес") Тогда
		
		Результат.Вставить("id",               "");
		Результат.Вставить("areaCode",         "");
		Результат.Вставить("areaId",           "");
		Результат.Вставить("district",         "");
		Результат.Вставить("districtType",     "");
		Результат.Вставить("districtId",       "");
		Результат.Вставить("munDistrict",      "");
		Результат.Вставить("munDistrictType",  "");
		Результат.Вставить("munDistrictId",    "");
		Результат.Вставить("cityId",           "");
		Результат.Вставить("settlement",       "");
		Результат.Вставить("settlementType",   "");
		Результат.Вставить("settlementId",     "");
		Результат.Вставить("cityDistrict",     "");
		Результат.Вставить("cityDistrictType", "");
		Результат.Вставить("cityDistrictId",   "");
		Результат.Вставить("territory",        "");
		Результат.Вставить("territoryType",    "");
		Результат.Вставить("territoryId",      "");
		Результат.Вставить("locality",         "");
		Результат.Вставить("localityType",     "");
		Результат.Вставить("localityId",       "");
		Результат.Вставить("streetId",         "");
		Результат.Вставить("houseType",        "");
		Результат.Вставить("houseNumber",      "");
		Результат.Вставить("houseId",          "");
		Результат.Вставить("buildings",        Новый Массив);
		Результат.Вставить("apartments",       Новый Массив);
		Результат.Вставить("codeKLADR",        "");
		Результат.Вставить("oktmo",            "");
		Результат.Вставить("okato",            "");
		Результат.Вставить("asInDocument",     "");
		Результат.Вставить("ifnsFLCode",       "");
		Результат.Вставить("ifnsULCode",       "");
		Результат.Вставить("ifnsFLAreaCode",   "");
		Результат.Вставить("ifnsULAreaCode",   "");
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция СопоставлениеНаименованиеУровнюАдреса(ИмяУровня) Экспорт
	Уровни = Новый Соответствие;
	
	Уровни.Вставить("Area", 1);
	Уровни.Вставить("MunDistrict", 31);
	Уровни.Вставить("Settlement", 41);
	Уровни.Вставить("District", 3);
	Уровни.Вставить("City", 4);
	Уровни.Вставить("CityDistrict", 5);
	Уровни.Вставить("Locality", 6);
	Уровни.Вставить("Territory", 65);
	Уровни.Вставить("Street", 7);
	
	Возврат Уровни[ИмяУровня];
КонецФункции

Функция ИменаУровнейАдреса(ТипАдреса, ВключатьУлицу) Экспорт
	Уровни = Новый Массив;
	
	Если ТипАдреса = УправлениеКонтактнойИнформациейКлиентСервер.ИностранныйАдрес() Тогда
		
		Уровни.Добавить("City");
		
	Иначе
		
		Уровни.Добавить("Area");
		Если ТипАдреса = УправлениеКонтактнойИнформациейКлиентСервер.АдресЕАЭС() Тогда
			
			Уровни.Добавить("District");
			Уровни.Добавить("City");
			Уровни.Добавить("Locality");
			
		Иначе
			
			Если ТипАдреса = "Все" Тогда
				Уровни.Добавить("District");
				Уровни.Добавить("City");
				Уровни.Добавить("MunDistrict");
				Уровни.Добавить("Settlement");
			Иначе
				Если ЭтоМуниципальныйАдрес(ТипАдреса) Тогда
					Уровни.Добавить("MunDistrict");
					Уровни.Добавить("Settlement");
				Иначе
					Уровни.Добавить("District");
					Уровни.Добавить("City");
				КонецЕсли;
			КонецЕсли;
			
			Уровни.Добавить("CityDistrict");
			Уровни.Добавить("Locality");
			Уровни.Добавить("Territory");
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ВключатьУлицу Тогда
			Уровни.Добавить("Street");
		КонецЕсли;
	Возврат Уровни;
	
КонецФункции

Процедура ОбновитьПредставлениеАдреса(Адрес, ВключатьСтрануВПредставление) Экспорт
	
	Представление = ПредставлениеАдреса(Адрес, ВключатьСтрануВПредставление);
	Адрес.Value = Представление;
	
КонецПроцедуры

Функция ПредставлениеАдреса(Адрес, ВключатьСтрануВПредставление, ТипАдреса = Неопределено) Экспорт
	
	Если ТипЗнч(Адрес) <> Тип("Структура") Тогда
		ВызватьИсключение НСтр("ru='Для формирования представления адреса передан некорректный тип адреса'");
	КонецЕсли;
	
	Если ТипАдреса = Неопределено Тогда
		ТипАдреса = Адрес.AddressType;
	КонецЕсли;
	
	Если УправлениеКонтактнойИнформациейКлиентСервер.ЭтоАдресВСвободнойФорме(ТипАдреса) Тогда
		
		Если Не Адрес.Свойство("Country") Или ПустаяСтрока(Адрес.Country) Тогда
			Возврат Адрес.Value;
		КонецЕсли;
		
		ВПредставлениеЕстьСтрана = СтрНачинаетсяС(ВРег(Адрес.Value), ВРег(Адрес.Country));
		Если ВключатьСтрануВПредставление Тогда
			Если Не ВПредставлениеЕстьСтрана Тогда
				Возврат Адрес.Country + ", " + Адрес.Value;
			КонецЕсли;
		Иначе
			Если ВПредставлениеЕстьСтрана И СтрНайти(Адрес.Value, ",") > 0 Тогда
				СписокПолей = СтрРазделить(Адрес.Value, ",");
				СписокПолей.Удалить(0);
				Возврат СтрСоединить(СписокПолей, ",");
			КонецЕсли;
		КонецЕсли;
		
		Возврат Адрес.Value;
		
	КонецЕсли;
	
	Если УправлениеКонтактнойИнформациейКлиентСервер.ЭтоАдресВСвободнойФорме(ТипАдреса) Тогда
		Возврат ПредставлениеАдресаВСвободнойФорме(Адрес, ВключатьСтрануВПредставление);
	КонецЕсли;
	
	СписокЗаполненныхУровней = Новый Массив;
	
	НаименованиеСтраны = "";
	Если ВключатьСтрануВПредставление И Адрес.Свойство("Country") И НЕ ПустаяСтрока(Адрес.Country) Тогда
		СписокЗаполненныхУровней.Добавить(Адрес.Country);
		НаименованиеСтраны = Адрес.Country;
	КонецЕсли;
	
	Если Адрес.Свойство("ZipCode") И НЕ ПустаяСтрока(Адрес.ZipCode) Тогда
		СписокЗаполненныхУровней.Добавить(Адрес.ZipCode);
	КонецЕсли;
	
	Для каждого ИмяУровня Из ИменаУровнейАдреса(ТипАдреса, Истина) Цикл
		
		Если Адрес.Свойство(ИмяУровня) И НЕ ПустаяСтрока(Адрес[ИмяУровня]) Тогда
			Если НЕ ПредставлениеУровняБезСокращения(ИмяУровня) Тогда
				СписокЗаполненныхУровней.Добавить(СокрЛП(Адрес[ИмяУровня] + " " + Адрес[ИмяУровня + "Type"]));
			Иначе
				СписокЗаполненныхУровней.Добавить(Адрес[ИмяУровня]);
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
	Если Адрес.Свойство("HouseNumber") И НЕ ПустаяСтрока(Адрес.HouseNumber) Тогда
		СписокЗаполненныхУровней.Добавить(НРег(Адрес.HouseType) + " " + Адрес.HouseNumber);
	КонецЕсли;
	
	Если Адрес.Свойство("Buildings") И Адрес.Buildings.Количество() > 0 Тогда
		
		Для каждого Строение Из Адрес.Buildings Цикл
			Если ЗначениеЗаполнено(Строение.Number) Тогда
				СписокЗаполненныхУровней.Добавить(НРег(Строение.Type) + " " + Строение.Number);
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	Если Адрес.Свойство("Apartments")
		И Адрес.Apartments <> Неопределено
		И Адрес.Apartments.Количество() > 0 Тогда
		
		Для каждого Строение Из Адрес.Apartments Цикл
			Если ЗначениеЗаполнено(Строение.Number) Тогда
				Если СтрСравнить(Строение.Type, "Другое") <> 0 Тогда
					СписокЗаполненныхУровней.Добавить(НРег(Строение.Type) + " " + Строение.Number);
				Иначе
					СписокЗаполненныхУровней.Добавить(Строение.Number);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	Представление = СтрСоединить(СписокЗаполненныхУровней, ", ");
	
	Возврат Представление;
	
КонецФункции

#Область ПрочиеСлужебныеПроцедурыИФункции

Функция ПредставлениеУровняБезСокращения(ИмяУровня) Экспорт
	
	Если ИмяУровня = "MunDistrict" ИЛИ ИмяУровня = "Settlement" Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ПредставлениеАдресаВСвободнойФорме(Знач Адрес, Знач ВключатьСтрануВПредставление)
	
	Если ВключатьСтрануВПредставление И Адрес.Свойство("Country") И НЕ ПустаяСтрока(Адрес.Country) Тогда
		ЧастиАдреса = СтрРазделить(Адрес.Value, ",");
		Если ЗначениеЗаполнено(Адрес.Value) И СтрСравнить(ЧастиАдреса[0], Адрес.Country) = 0 Тогда
			ЧастиАдреса.Удалить(0);
			Адрес.Value = СтрСоединить(ЧастиАдреса, ",");
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Адрес.Value;
	
КонецФункции

// Возвращает пустую структура адреса.
//
// Возвращаемое значение:
//    Структура - адрес, ключи - имена полей, значения поля.
//
Функция СтруктураПолейАдреса(ФорматАдреса)
	
	СтруктураАдреса = Новый Структура;
	СтруктураАдреса.Вставить("Представление", "");
	СтруктураАдреса.Вставить("Страна", "");
	СтруктураАдреса.Вставить("НаименованиеСтраны", "");
	СтруктураАдреса.Вставить("КодСтраны","");
	СтруктураАдреса.Вставить("Индекс","");
	СтруктураАдреса.Вставить("Регион","");
	СтруктураАдреса.Вставить("РегионСокращение","");
	СтруктураАдреса.Вставить("Район","");
	СтруктураАдреса.Вставить("РайонСокращение","");
	СтруктураАдреса.Вставить("Город","");
	СтруктураАдреса.Вставить("ГородСокращение","");
	СтруктураАдреса.Вставить("НаселенныйПункт","");
	СтруктураАдреса.Вставить("НаселенныйПунктСокращение","");
	СтруктураАдреса.Вставить("Улица","");
	СтруктураАдреса.Вставить("УлицаСокращение","");
	СтруктураАдреса.Вставить("Дом","");
	СтруктураАдреса.Вставить("Корпус","");
	СтруктураАдреса.Вставить("Квартира","");
	СтруктураАдреса.Вставить("ТипДома","");
	СтруктураАдреса.Вставить("ТипКорпуса","");
	СтруктураАдреса.Вставить("ТипКвартиры","");
	СтруктураАдреса.Вставить("НаименованиеВида","");
	
	Если ВРег(ФорматАдреса) = "ФИАС" Тогда
		СтруктураАдреса.Вставить("Округ","");
		СтруктураАдреса.Вставить("ОкругСокращение","");
		СтруктураАдреса.Вставить("ВнутригородскойРайон","");
		СтруктураАдреса.Вставить("ВнутригородскойРайонСокращение","");
	КонецЕсли;
	
	Возврат СтруктураАдреса;
	
КонецФункции

#КонецОбласти

#КонецОбласти
