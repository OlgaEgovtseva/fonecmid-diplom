
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Ответственный = Пользователи.ТекущийПользователь();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;
	
	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;
	//ВКМ_Еговцева_Ольга_12.08.24+ 
	Движение.ВКМ_СтоимостьУслуг =  Услуги.Итог("Сумма");
    //ВКМ_Еговцева_Ольга_12.08.24-

	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;

КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	ВидДоговора = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "ВидДоговора");
	
	Если ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание Тогда 

		ИндексЭлемента = ПроверяемыеРеквизиты.Найти("Основание");
		ПроверяемыеРеквизиты.Удалить(ИндексЭлемента);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказПокупателя.Организация КАК Организация,
	               |	ЗаказПокупателя.Контрагент КАК Контрагент,
	               |	ЗаказПокупателя.Договор КАК Договор,
	               |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
	               |	ЗаказПокупателя.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	ЗаказПокупателя.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	               |ГДЕ
	               |	ЗаказПокупателя.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
	
	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;
	
	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;
	
	Основание = ДанныеЗаполнения;
	
КонецПроцедуры

Процедура ВКМ_ВыполнитьАвтозаполнение() Экспорт 
	
	НоменклатураАбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	НоменклатураРаботыСпециалиста = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	
	Если НЕ ЗначениеЗаполнено(НоменклатураАбонентскаяПлата) ИЛИ НЕ ЗначениеЗаполнено(НоменклатураРаботыСпециалиста) Тогда 
		ОбщегоНазначения.СообщитьПользователю("Проверьте заполнение констант НоменклатураАбонентскаяПлата и НоменклатураРаботыСпециалиста");
		Возврат;
	КонецЕсли; 
	
	Услуги.Очистить();
	
	СуммаДоговора = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "ВКМ_СуммаАбонентскойПлаты");
	
	Если СуммаДоговора <> 0 Тогда
		НоваяУслуга = Услуги.Добавить();
		НоваяУслуга.Номенклатура = НоменклатураАбонентскаяПлата;
		НоваяУслуга.Цена = СуммаДоговора;
		НоваяУслуга.Количество = 1;
		НоваяУслуга.Сумма = СуммаДоговора;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.КоличествоЧасовОборот, 0) КАК КоличествоЧасов,
	|	ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.СуммаКОплатеОборот, 0) КАК СуммаКОплате,
	|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Период КАК Период,
	|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Договор.Представление
	|ИЗ
	|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(&ДатаНачало, &ДатаКонец, Месяц, Договор = &Договор) КАК
	|		ВКМ_ВыполненныеКлиентуРаботыОбороты
	|ГДЕ
	|	&Дата
	|		МЕЖДУ ВКМ_ВыполненныеКлиентуРаботыОбороты.Договор.ВКМ_ДействуетС И ВКМ_ВыполненныеКлиентуРаботыОбороты.Договор.ВКМ_ДействуетПо";
	
	Запрос.УстановитьПараметр("Договор", Договор);
	Запрос.УстановитьПараметр("ДатаНачало", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("ДатаКонец", КонецМесяца(Дата));
	Запрос.УстановитьПараметр("Дата", Дата);
	
	ТабЗн = Запрос.Выполнить().Выгрузить();
	
	Если ТабЗн.Количество() Тогда
		НоваяУслуга = Услуги.Добавить();
		НоваяУслуга.Номенклатура = НоменклатураРаботыСпециалиста;
		НоваяУслуга.Количество = ТабЗн.Итог("КоличествоЧасов");
		НоваяУслуга.Сумма = ТабЗн.Итог("СуммаКОплате");
		НоваяУслуга.Цена = НоваяУслуга.Сумма / НоваяУслуга.Количество;
	КонецЕсли;
	
	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");

КонецПроцедуры

#КонецОбласти

#КонецЕсли
