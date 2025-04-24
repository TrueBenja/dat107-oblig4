package no.hvl.dat107.oblig4.repository;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

import com.mongodb.client.model.FindOneAndReplaceOptions;
import com.mongodb.client.model.ReturnDocument;

import static com.mongodb.client.model.Filters.eq;

import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.model.Updates;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;

import no.hvl.dat107.oblig4.entity.Kunde;

public class KundeRepository {
	private MongoClient client;
	private MongoDatabase db;
	private MongoCollection<Kunde> kunder;
	
	public KundeRepository(MongoClient client) {
		super();
		this.client = client;
		this.db = client.getDatabase("oblig4-db");
		this.kunder = db.getCollection("kunde", Kunde.class);
	}
	
	public Kunde findByKnr(Integer knr) {
		Bson filter = eq("knr", knr);
		return kunder.find(filter).first();
	}

	public Kunde save(Kunde nyKunde) {
		kunder.insertOne(nyKunde);
		return nyKunde;
	}

	public Kunde delete(int id) {
		return kunder.findOneAndDelete(eq("knr", id));
	}

	public Kunde update(ObjectId id, Kunde endretKunde) {
		Bson filter = eq("_id", id);
		UpdateOptions options = new UpdateOptions().upsert(true);

		Bson oppdateringer = Updates.combine(
				Updates.set("knr", endretKunde.getKundeNr()),
				Updates.set("fornavn", endretKunde.getFornavn()),
				Updates.set("etternavn", endretKunde.getEtternavn()),
				Updates.set("adresse", endretKunde.getAdresse()),
				Updates.set("postnr", endretKunde.getPostnr())
		);

		kunder.updateOne(filter, oppdateringer, options);
		return endretKunde;
	}
}
