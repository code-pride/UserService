package pl.codepride.dailyadvisor.userservice.repository;

import org.springframework.data.cassandra.repository.CassandraRepository;
import pl.codepride.dailyadvisor.userservice.model.entity.TokenJWT;

import java.util.UUID;

public interface TokenJWTRepository extends CassandraRepository<TokenJWT, UUID> {

}
